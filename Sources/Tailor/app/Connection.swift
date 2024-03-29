import Foundation
import COpenSSL
#if os(Linux)
  import Glibc
#endif

/**
  This class represents a connection with a client.
  */
public final class Connection {
  
  /** A callback that can be given a response. */
  public typealias ResponseCallback = (Response)->Void
  
  /** A closure that can process a request. */
  public typealias RequestHandler = (Request, ResponseCallback)->()
  
  /** The file descriptor that we are using to communicate with the client.*/
  let socketDescriptor: Int32
  
  /** A callback to the code to provide the request, if this is an inbound connection. */
  let requestHandler: RequestHandler?
  
  /** A callback to the code to provide the response, if this is an outbound connection. */
  let responseHandler: ResponseCallback?

  /** The SSL connection that we are using to communicate with the other party. */
  var sslConnection: UnsafeMutablePointer<SSL> = nil
  
  /**
    This type provides errors that are thrown by connections.
    */
  public enum Error: ErrorType {
    /**
      This error is thrown when we fail to open a socket.
      
      The parameter is the errno value after the socket call.
      */
    case CouldNotOpenSocket(Int32)
    
    /**
      This error is thrown when we fail to establish a connection with another server.
      
      The parameter is the 32-bit integer with the IP address we tried to connect to.
      */
    case CouldNotConnectToServer(UInt32)
    
    /** This error is thrown when we are unable to get an IP address from a domain. */
    case CouldNotResolveDomain
  }
  
  /**
    The queue that we put requests on.
    */
  #if os(Linux)
  #else
    public static let dispatchQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
  #endif
  
  /**
    This method creates a new connection for listening to incoming requests.

    - parameter fileDescriptor:     The file descriptor for the socket that we
                                    are using for the connection.
    - parameter requestHandler:     A callback that will handle the request.
    */
  public init(fileDescriptor: Int32, requestHandler: RequestHandler) {
    self.socketDescriptor = fileDescriptor
    self.requestHandler = requestHandler
    self.responseHandler = nil
    CONNECTION_POOL[fileDescriptor] = self
    self.listenToSocket()
  }

  /**
    This method creates a new connection for sending requests to other servers.

    - parameter fileDescriptor:     The file descriptor for the socket that we
                                    are using for the connection.
    - parameter responseHandler:    A callback that will handle the response
                                    from the other server.
    */
  public init(fileDescriptor: Int32, responseHandler: ResponseCallback) {
    self.socketDescriptor = fileDescriptor
    self.requestHandler = nil
    self.responseHandler = responseHandler
    CONNECTION_POOL[fileDescriptor] = self
  }
  
  //MARK: - Handling Requests

  /**
    This method adds an operation to the main queue for getting a connection for
    our socket.
  
    This will return immediately after putting the operation in the queue.
  
    Once the connection is accepted, it will put an operation on a new
    queue for reading from the socket, and put an operation on the main queue
    for listening for a new connection.
    */
  public func listenToSocket() {
    if self.socketDescriptor < 0 {
      return
    }
    #if os(Linux)
      self.spawnThread(ConnectionAcceptInThread, descriptor: 0)
    #else
      NSOperationQueue.mainQueue().addOperationWithBlock {
        let connectionDescriptor = Connection.accept(self.socketDescriptor)
        
        if connectionDescriptor > 0 {
          dispatch_async(Connection.dispatchQueue) {
            self.readRequestFromSocket(connectionDescriptor)
          }
        }
        self.listenToSocket()
      }
    #endif
  }

  /**
    This method reads an HTTP message from a connection.

    This reads the message synchronously.

    - parameter connectionDescriptor:   The file descriptor we are reading from.
    - parameter callback:               The callback to invoke with the message.
    */
  private func readMessageFromSocket<MessageType: HttpMessageType>(connectionDescriptor: Int32, @noescape callback: (MessageType)->Void) {
    let data = NSMutableData()
    let bufferLength = 1024
    var buffer = [UInt8](count: Int(bufferLength), repeatedValue: 0)
    var message = MessageType(data: NSData())
    
    while true {
      let length = Connection.read(connectionDescriptor, sslConnection: sslConnection, buffer: &buffer, maxLength: bufferLength)
      if length < 0 || length > Int(bufferLength) {
        Connection.close(connectionDescriptor)
        return
      }
      data.appendBytes(buffer, length: length)
      if length < bufferLength {
        message = MessageType(data: data)
        if message.headers["Expect"] == "100-continue", let request = message as? Request {
          var response = Response()
          response.responseCode = RouteSet.shared().canHandleRequest(request) ? .Continue : .NotFound
          self.writeMessage(response, toSocket: connectionDescriptor)
        }
        if let headerLength = Int(message.headers["Content-Length"] ?? "") {
          if message.bodyData.length > headerLength {
            let finalData = data.subdataWithRange(NSMakeRange(0, data.length + headerLength - message.bodyData.length))
            message = MessageType(data: finalData)
            break
          }
          else if message.bodyData.length == headerLength {
            break
          }
        }
        else if message.headers["Transfer-Encoding"]?.hasPrefix("chunked") ?? false {
          let headerAndBody = data.componentsSeparatedByString("\r\n\r\n", limit: 2)
          guard headerAndBody.count > 1 else { break }
          let header = headerAndBody[0]
          let body = headerAndBody[1]
          guard let decodedBody = Connection.decodeChunkedData(body) else { continue }
          let decodedData = NSMutableData()
          decodedData.appendData(header)
          decodedData.appendData(NSData(bytes: "\r\nContent-Length: \(decodedBody.length)\r\n\r\n".utf8))
          decodedData.appendData(decodedBody)
          message = MessageType(data: decodedData)
          break
        }
        else {
          break
        }
      }
    }
    callback(message)
  }

  /**
    This method writes a message to a connection.

    If the connection has an SSL connection associated to it, this will write to
    that instead of writing to the file descriptor.

    - parameter message:                The message that we are writing.
    - parameter connectionDescriptor:   The file descriptor we are writing to.
    - returns:                          The number of bytes we wrote.
    */
  private func writeMessage(message: HttpMessageType, toSocket connectionDescriptor: Int32) -> Int {
    return Connection.write(connectionDescriptor, sslConnection: sslConnection, data: message.data)  
  }

  /**
    This method closes the connection.

    This will shutdown the socket and the associated SSL connection, and will
    remove it from the connection pool.

    After this is done the connection cannot be re-opened and cannot receive
    any further requests.
    */
  private func close() {
    if sslConnection != nil {
      SSL_shutdown(sslConnection)
      SSL_free(sslConnection)
    }
    shutdown(socketDescriptor, Int32(SHUT_RDWR))
    Connection.close(socketDescriptor)
    CONNECTION_POOL.removeValueForKey(socketDescriptor)
  }
  
  /**
    This method reads the available data from a socket.
    
    It will read the data and process the request synchronously, then write the
    response data to the file descriptor and close it.
    
    This has been deprecated in favor of readRequestFromSocket.
  
    - parameter connectionDescriptor:    The file descriptor for the connection.
    */
  @available(*, deprecated, message="Use readRequestFromSocket instead")
  public func readFromSocket(connectionDescriptor: Int32) {
    self.readRequestFromSocket(connectionDescriptor)
  }
  
  /**
    This method reads the available data from a socket.
    
    It will read the data and process the request synchronously, then write the
    response data to the file descriptor and close it.
  
    - parameter connectionDescriptor:    The file descriptor for the connection.
    */
  public func readRequestFromSocket(connectionDescriptor: Int32) {
    var startTime: Timestamp? = nil
    
    #if os(Linux)
    var clientAddress = sockaddr(
      sa_family: 0,
      sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    )
    #else
    var clientAddress = sockaddr(
      sa_len: 0,
      sa_family: 0,
      sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    )
    #endif

    var size = UInt32(sizeof(sockaddr))
    Connection.getpeername(connectionDescriptor, address: &clientAddress, addressLength: &size)
    let clientAddressString = "\(clientAddress.sa_data.2).\(clientAddress.sa_data.3).\(clientAddress.sa_data.4).\(clientAddress.sa_data.5)"
    let sslConnection = self.sslConnection
    self.readMessageFromSocket(connectionDescriptor) {
      (request: Request) in
      var request = request
      request.secure = false
      request.clientAddress = clientAddressString
      startTime = Timestamp.now()
      
      self.requestHandler?(request) {
        response in
        
        let responseData = response.data
        if response.chunked && response.bodyOnly {
          let length = [responseData.length] as [CVarArgType]
          withVaList(length) {
            let length = NSString(format: "%x", arguments: $0)
            let lengthData = NSData(bytes: "\(length)\r\n".utf8)
            Connection.write(connectionDescriptor, sslConnection: sslConnection, data: lengthData)
          }
        }
        

        let bytesWritten = self.writeMessage(response, toSocket: connectionDescriptor)
        
        if(bytesWritten == -1) {
          response.continuationCallback?(false)
          return
        }
        
        if response.chunked && response.bodyOnly {
          Connection.write(connectionDescriptor, sslConnection: sslConnection, data: NSData(bytes: "\r\n".utf8))
        }
        
        response.continuationCallback?(true)
        
        if !response.hasDefinedLength && responseData.length > 0 {
          return
        }
        
        if let startTime = startTime {
          let interval = Timestamp.now().epochSeconds - startTime.epochSeconds
          NSLog("Finished processing %@ in %@ seconds", request.path, String(interval))
        }
        if request.headers["Connection"] == "close" || response.headers["Connection"] == "close" {
          Connection.close(connectionDescriptor)
        }
        else if Connection.stubbing {
          self.readRequestFromSocket(connectionDescriptor)
        }
        else {
          #if os(Linux)
            self.spawnThread(ConnectionReadRequestInThread, descriptor: connectionDescriptor)
          #else
          dispatch_async(Connection.dispatchQueue) {
            self.readRequestFromSocket(connectionDescriptor)
          }
          #endif
        }
      }
    }
  }
  
  /**
    This method creates a new socket.

    - returns:    The socket file descriptor.
    - throws:     An `Error` if we cannot open a socket.
    */
  private static func createSocket() throws -> Int32 {
    #if os(Linux)
      let socketDescriptor = socket(PF_INET, Int32(SOCK_STREAM.rawValue), Int32(IPPROTO_TCP))
    #else
      let socketDescriptor = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
    #endif
    let flag = [1]
    setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEADDR, flag, UInt32(sizeof(Int)))
    setsockopt(socketDescriptor, SOL_SOCKET, SO_KEEPALIVE, flag, UInt32(sizeof(Int)))
    
    if socketDescriptor == -1 {
      throw Error.CouldNotOpenSocket(errno)
    }
    return socketDescriptor
  }
  
  /**
    This method opens a connection to another server.

    - parameter domain:     The domain that we are connecting to.
    - parameter port:       The port to connect on.
    - parameter callback:   The callback that the connection should invoke it
                            has a response.
    - returns:              The connection.
    */
  private static func connectToServer(domain: String, port: Int, callback: ResponseCallback) throws -> Connection {
    var addressPointer = UnsafeMutablePointer<addrinfo>(nil)
    _ = getaddrinfo(domain, nil, nil, &addressPointer)
    while addressPointer != nil {
      let address = addressPointer.memory
      #if os(Linux)
        let serverProtocol = Int(address.ai_protocol)
      #else
        let serverProtocol = Int32(address.ai_protocol)
      #endif
      if serverProtocol == IPPROTO_TCP && address.ai_family == PF_INET {
        let socketDescriptor = try createSocket()
        
        let ipv4Address = UnsafeMutablePointer<sockaddr_in>(address.ai_addr)
        ipv4Address.memory.sin_port = UInt16(((port & 0xFF) << 8) | ((port >> 8) & 0xFF))
        
        if connect(socketDescriptor, address.ai_addr, address.ai_addrlen) == -1 {
          throw Error.CouldNotConnectToServer(ipv4Address.memory.sin_addr.s_addr)
        }
        
        return Connection(fileDescriptor: socketDescriptor, responseHandler: callback)
      }
    }
    throw Error.CouldNotResolveDomain
  }

  /**
    This method gets the shared SSL context for outbound connections.
    */
  private static var sslContext: UnsafeMutablePointer<SSL_CTX> {
    if SSL_CONTEXT == nil {
      SSL_library_init()
      let method = SSLv23_method()
      SSL_CONTEXT = SSL_CTX_new(method)
    }
    return SSL_CONTEXT
  }

  /**
    This method opens an SSL connection for a connection.

    This will set it as the `sslConnection` field on the connection.

    - parameter connection:   The connection that we should tie the SSL
                              connection to.
    */
  private static func openSSLConnection(connection: Connection) {
    let sslConnection = SSL_new(sslContext)
    SSL_set_fd(sslConnection, connection.socketDescriptor)
    SSL_connect(sslConnection)
    connection.sslConnection = sslConnection
  }

  /**
    This method makes a request to another service.

    This will open the connection and send the request synchronously, and then
    spawn a new thread to wait for the response.

    - parameter request:    The request to send.
    - parameter callback:   The callback to invoke when we have a response.
    */
  public static func sendRequest(request: Request, callback: Connection.ResponseCallback) {
    var _connection: Connection? = nil
    do {
      let port = request.secure ? 443 : 80
      let connection = try connectToServer(request.domain, port: port) {
        response in
        callback(response)
        _connection?.close()
      }
      _connection = connection
      if request.secure {
        openSSLConnection(connection)
      }
      connection.writeMessage(request, toSocket: connection.socketDescriptor)
      connection.spawnThread(ConnectionReadResponseInThread, descriptor: 0)
    }
    catch {
      NSLog("Error connecting to host: \(request.domain)")
      var response = Response()
      response.responseCode = Response.Code(500, "Server Not Reachable")
      callback(response)
    }
  }

  /**
    This method makes a request to another service.

    This will send the request and wait for the response synchronously.

    - parameter request:    The request to send.
    - returns:              The response.
    */
  public static func sendRequest(request: Request) -> Response {
    var response = Response()
    response.responseCode = Response.Code(500, "Server Not Reachable")

    do {
      let port = request.secure ? 443 : 80
      let connection = try connectToServer(request.domain, port: port) {
        _ in
      }
      if request.secure {
        openSSLConnection(connection)
      }
      connection.writeMessage(request, toSocket: connection.socketDescriptor)

      connection.readMessageFromSocket(connection.socketDescriptor) {
        _response in
        response = _response
      }
      connection.close()
    }
    catch {
      NSLog("Error connecting to host: \(request.domain)")
    }
    return response
  }
  
  /**
    This method takes data that has been encoded with the chunked
    transfer-coding and decodes it.
    
    If the input data is incomplete, this will return nil.

    - parameter input:    The encoded data
    - returns:            The decoded data
    */
  internal static func decodeChunkedData(input: NSData) -> NSData? {
    let output = NSMutableData()
    let lines = input.componentsSeparatedByString("\r\n")
    let newline = NSData(bytes: "\r\n".utf8)
    var remainingChunkLength = 0
    var hasCompleteRequest = false
    for line in lines {
      if remainingChunkLength == 0 {
        let chunkLengthString = NSString(data: line, encoding: NSASCIIStringEncoding) ?? ""
        
        if chunkLengthString == "0" {
          hasCompleteRequest = true
          break
        }
        let scanner = NSScanner(string: chunkLengthString.bridge())
        var newChunkLength: UInt32 = 0
        scanner.scanHexInt(&newChunkLength)
        remainingChunkLength = Int(newChunkLength)
        continue
      }
      
      if line.length >= remainingChunkLength {
        output.appendData(line.subdataWithRange(NSMakeRange(0, remainingChunkLength)))
        remainingChunkLength = 0
      }
      else {
        remainingChunkLength -= line.length + 2
        output.appendData(line)
        output.appendData(newline)
      }
    }
    if hasCompleteRequest {
      return output
    }
    else {
      return nil
    }
  }

  /**
    This method spawns a new thread for taking action on this connection.

    The function that we are invoking in the new thread must accept a pointer to
    a buffer of Int32 values. The first value in this pointer will be the
    connection's socket descriptor, and the second value will be the descriptor
    given to this call. The target function must free that buffer pointer.

    - parameter function:     A global function to call in the new thread.
    - parameter description:  The additional descriptor to pass to the function.
    */
  private func spawnThread(function: @convention(c) UnsafeMutablePointer<Void> -> UnsafeMutablePointer<Void>, descriptor: Int32) {
    let buffer = UnsafeMutablePointer<Int32>(calloc(sizeof(Int32.self), 2))
    buffer[0] = self.socketDescriptor
    buffer[1] = descriptor
    var thread = pthread_t()
    pthread_create(&thread, nil, function, buffer)
  }

  /**
    This method starts the server.

    It will open the connection and then tell the run loop to run indefinitely.

    - parameter address:    The IP address to listen on.
    - parameter port:       The port to listen on.
    - parameter handler:    A callback that will be called when a request is
                            ready for processing. This will be given a request
                            and another callback that it can call with a
                            response.
    - returns:              Whether we were able to open the connection.
    */
  public static func startServer(address: (Int,Int,Int,Int), port: Int, handler: RequestHandler) -> Bool {
    let socketDescriptor: Int32
    do {
      socketDescriptor = try createSocket()
    }
    catch {
      NSLog("Error creating socket")
      return false
    }
    
    var socketAddress = sockaddr_in()
    #if os(Linux)
    socketAddress.sin_family = UInt16(AF_INET)
    socketAddress.sin_port = UInt16((port & 0xFF) << 8 | port >> 8)
    #else
    socketAddress.sin_family = UInt8(AF_INET)
    socketAddress.sin_port = CFSwapInt16(UInt16(port))
    #endif
    socketAddress.sin_addr.s_addr = UInt32(address.0 | address.1 << 8 | address.2 << 16 | address.3 << 24)
    
    func socketAddressPointer(pointer: UnsafePointer<sockaddr_in>) -> UnsafePointer<sockaddr> {
      return UnsafePointer<sockaddr>(pointer)
    }

    if bind(socketDescriptor, socketAddressPointer(&socketAddress), UInt32(sizeof(sockaddr_in))) == -1 {
      NSLog("Error binding to socket")
      close(socketDescriptor)
      return false
    }
    
    if listen(socketDescriptor, 10) == -1 {
      NSLog("Error listening on socket")
      close(socketDescriptor)
      return false
    }
    
    signal(SIGPIPE, SIG_IGN)
    NSLog("Listening on port %d", port)
    _ = Connection(fileDescriptor: socketDescriptor, requestHandler: handler)

    #if os(Linux)
    while(true) {
      sleep(1)
    }
    #else
    NSRunLoop.currentRunLoop().run()
    return true
    #endif
  }
  
  //MARK: - Stubbing
  
  /** Whether we are currently stubbing out connections. */
  internal private(set) static var stubbing: Bool = false
  
  /** The file descriptors that we have accepted stubbed connections on. */
  internal private(set) static var acceptedSockets: [Int32] = []
  
  /** The file descriptors that we have read stubbed data from. */
  internal private(set) static var readConnections: [Int32] = []
  
  /** The file descriptors that we have closed in stubbed connections. */
  internal private(set) static var closedConnections: [Int32] = []
  
  /** The data that we should provide to stubbed connections. */
  internal private(set) static var stubbedData: [NSData] = []
  
  /** The data that we have written to stubbed connections. */
  internal private(set) static var outputData = NSMutableData()
  
  /**
    This method causes the connections to stub out all of their communications.

    - parameter data:   The data to provide when reading from stubbed
                        connections. If there are multiple values in the array,
                        then a separate call to `read` will be required to go
                        from one data object to the next.
    */
  internal static func startStubbing(data: [NSData] = []) {
    stubbing = true
    acceptedSockets = []
    readConnections = []
    closedConnections = []
    stubbedData = data
    outputData = NSMutableData()
  }
  
  /**
    This method causes the connections to stop stubbing out communication.
    */
  internal static func stopStubbing() {
    stubbing = false
  }
  
  /**
    This method accepts a connection on a socket.

    - parameter socketDescriptor:   The socket that we are listening on.
    */
  internal static func accept(socketDescriptor: Int32) -> Int32 {
    if stubbing {
      if !acceptedSockets.isEmpty {
        return -1
      }
      acceptedSockets.append(socketDescriptor)
      return socketDescriptor + 1
    }
    else {
      #if os(Linux)
        return Glibc.accept(socketDescriptor, nil, nil)
      #else
        return Foundation.accept(socketDescriptor, nil, nil)
      #endif
    }
  }
  
  /**
    This method gets the client address from a connection.

    - parameter connection:     The connection that we are reading from.
    - parameter address:        A pointer holding the address.
    - parameter addressLength:  A pointer holding the number of bytes in the
                                address.
    - returns:                  Whether we were able to get the client address.
    */
  internal static func getpeername(connection: Int32, address: UnsafeMutablePointer<sockaddr>, addressLength: UnsafeMutablePointer<socklen_t>) -> Int32 {
    if stubbing {
      address.memory.sa_data = (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
      return 0
    }
    else {
      #if os(Linux)
        return Glibc.getpeername(connection, address, addressLength)
      #else
        return Foundation.getpeername(connection, address, addressLength)
      #endif
    }
  }
  
  /**
    This method reads data from a connection.

    - parameter connection:       The connection handle that we are reading from.
    - parameter sslConnection:    The SSL connection to read from.
    - parameter buffer:           The buffer that we are reading into.
    - parameter maxLength:        The maximum size of the buffer.
    - returns:                    The number of bytes that we actually read.
    */
  private static func read(connection: Int32, sslConnection: UnsafeMutablePointer<SSL>, buffer: UnsafeMutablePointer<Void>, maxLength: Int) -> Int {
    if stubbing {
      readConnections.append(connection)
      if stubbedData.isEmpty { return -1 }
      let firstData = stubbedData[0]
      if maxLength < firstData.length {
        firstData.getBytes(buffer, length: maxLength)
        stubbedData[0] = firstData.subdataWithRange(NSMakeRange(maxLength, firstData.length - maxLength))
        return maxLength
      }
      else {
        let length = firstData.length
        firstData.getBytes(buffer, length: maxLength)
        stubbedData.removeAtIndex(0)
        return length
      }
    }
    else if sslConnection != nil {
      return Int(SSL_read(sslConnection, buffer, Int32(maxLength)))
    }
    else {
      #if os(Linux)
        return Glibc.read(connection, buffer, maxLength)
      #else
        return Foundation.read(connection, buffer, maxLength)
      #endif
    }
  }
  
  /**
    This method closes a connection.

    - parameter connection:   The connection to close.
    */
  private static func close(connection: Int32) {
    if stubbing {
      closedConnections.append(connection)
    }
    else {
      #if os(Linux)
        Glibc.close(connection)
      #else
        Foundation.close(connection)
      #endif
    }
  }
  
  /**
    This method writes data to a connection.

    - parameter connection:       The file descriptor to write to.
    - parameter sslConnection:    The SSL connection to write to.
    - parameter data:             The data to write to the connection.
    - returns:                    The number of bytes we wrote.
    */
  private static func write(connection: Int32, sslConnection: UnsafeMutablePointer<SSL>, data: NSData) -> Int {
    if stubbing {
      outputData.appendData(data)
      return data.length
    }
    else if sslConnection != nil {
      return Int(SSL_write(sslConnection, data.bytes, Int32(data.length)))
    }
    else {
      #if os(Linux)
        let result = Glibc.write(connection, data.bytes, data.length)
      #else
        let result = Foundation.write(connection, data.bytes, data.length)
      #endif
      return result
    }
  }
}

/**
  A dictionary of all of the open connections.

  The keys in this dictionary are the socket descriptors, and the values are
  the connections on those socket descriptors.
  */
private var CONNECTION_POOL: [Int32: Connection] = [:]

/**
  This function listens for incoming connections on a socket descriptor.

  Once a connection comes in, this will spawn a new thread to read from that
  connection. It will listen from a new connection in the current thread. It
  will continue listening for new connections until there is an error from
  `accept`, at which point this will return.

  This is designed to be used as an entry point for starting a new thread. 

  - parameter pointer:    A buffer pointer containing one 32-bit integer: the
                          socket descriptor that we are listening to. This will
                          be freed once the values are extracted.
  - returns:              This will always return nil
  */
func ConnectionAcceptInThread(pointer: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
  let buffer = UnsafeMutablePointer<Int32>(pointer)
  let socketDescriptor = buffer.memory
  free(buffer)
  guard let connection = CONNECTION_POOL[Int32(socketDescriptor)] else { return nil }
  
  repeat {
    let connectionDescriptor = Connection.accept(connection.socketDescriptor)
    if connectionDescriptor > 0 {
      connection.spawnThread(ConnectionReadRequestInThread, descriptor: connectionDescriptor)
    }
    else {
      break
    }
  } while true
  return nil
}

/**
  This function reads a request from a connection.

  This is designed to be used as an entry point for starting a new thread. 

  - parameter pointer:    A buffer pointer containing two 32-bit integers: the
                          socket descriptor that we are listening to and the
                          connection descriptor that we should read from. This
                          will be freed once the values are extracted.
  - returns:              This will always return nil
  */
func ConnectionReadRequestInThread(pointer: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
  let buffer = UnsafeMutablePointer<Int32>(pointer)
  let socketDescriptor = buffer[0]
  let connectionDescriptor = buffer[1]
  free(buffer)

  guard let connection = CONNECTION_POOL[Int32(socketDescriptor)] else { return nil }
  connection.readRequestFromSocket(connectionDescriptor)
  return nil
}

/**
  This function reads a response from a connection.

  This is designed to be used as an entry point for starting a new thread. 

  - parameter pointer:    A buffer pointer containing a 32-bit integer: the
                          socket descriptor that we are listening to.
  - returns:              This will always return nil
  */
func ConnectionReadResponseInThread(pointer: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<Void> {
  let buffer = UnsafeMutablePointer<Int32>(pointer)
  let socketDescriptor = buffer[0]
  free(buffer)

  guard let connection = CONNECTION_POOL[Int32(socketDescriptor)] else { return nil }
  connection.readMessageFromSocket(socketDescriptor) {
    response in
    connection.responseHandler?(response)
  }
  return nil 
}

private var SSL_CONTEXT: UnsafeMutablePointer<SSL_CTX> = nil