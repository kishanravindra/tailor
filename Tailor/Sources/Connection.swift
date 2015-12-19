import Foundation
#if os(Linux)
  import Glibc
#endif

/**
  This class represents a connection with a client.
  */
public struct Connection {
  
  /** A callback that can be given a response. */
  public typealias ResponseCallback = (Response)->Void
  
  /** A closure that can process a request. */
  public typealias RequestHandler = (Request, ResponseCallback)->()
  
  /** The file descriptor that we are using to communicate with the client.*/
  let socketDescriptor: Int32
  
  /** A callback to the code to provide the request. */
  let handler: RequestHandler
  
  /**
    The queue that we put requests on.
    FIXME
    */
  #if os(Linux)
    public static let dispatchQueue = 0
  #else
    public static let dispatchQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
  #endif
  
  /**
    This method creates a new connection.

    - parameter fileDescriptor:     The file descriptor for the socket that we
                                    are using for the connection.
    - parameter handler:            A callback that will handle the request.
    */
  public init(fileDescriptor: Int32, handler: RequestHandler) {
    self.socketDescriptor = fileDescriptor
    self.handler = handler
    self.listenToSocket()
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
  public mutating func listenToSocket() {
    if self.socketDescriptor < 0 {
      return
    }
    #if os(Linux)
      let connectionDescriptor = Connection.accept(self.socketDescriptor)
        
      if connectionDescriptor > 0 {
        self.readFromSocket(connectionDescriptor)
      }
      self.listenToSocket()
    #else
      NSOperationQueue.mainQueue().addOperationWithBlock {
        let connectionDescriptor = Connection.accept(self.socketDescriptor)
        
        if connectionDescriptor > 0 {
          #if os(Linux)
            self.readFromSocket(connectionDescriptor)
          #else
            dispatch_async(Connection.dispatchQueue) {
              self.readFromSocket(connectionDescriptor)
            }
          #endif
        }
        self.listenToSocket()
      }
    #endif
  }
  
  /**
    This method reads the available data from a socket.
    
    It will read the data and process the request synchronosuly, then write the
    response data to the file descriptor and close it.
  
    - parameter connectionDescriptor:    The file descriptor for the connection.
    */
  public mutating func readFromSocket(connectionDescriptor: Int32) {
    let data = NSMutableData()
    let bufferLength = 1024
    var buffer = [UInt8](count: Int(bufferLength), repeatedValue: 0)
    var request: Request = Request()
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
    
    while true {
      let length = Connection.read(connectionDescriptor, buffer: &buffer, maxLength: bufferLength)
      startTime = Timestamp.now()
      if length < 0 || length > Int(bufferLength) {
        Connection.close(connectionDescriptor)
        return
      }
      data.appendBytes(buffer, length: length)
      if length < bufferLength {
        request = Request(clientAddress: clientAddressString, data: data)
        if request.headers["Expect"] == "100-continue" {
          var response = Response()
          response.responseCode = RouteSet.shared().canHandleRequest(request) ? .Continue : .NotFound
          Connection.write(connectionDescriptor, data: response.data)
        }
        if let headerLength = Int(request.headers["Content-Length"] ?? "") {
          if request.body.length > headerLength {
            let finalData = data.subdataWithRange(NSMakeRange(0, data.length + headerLength - request.body.length))
            request = Request(clientAddress: clientAddressString, data: finalData)
            break
          }
          else if request.body.length == headerLength {
            break
          }
        }
        else if request.headers["Transfer-Encoding"]?.hasPrefix("chunked") ?? false {
          let headerAndBody = data.componentsSeparatedByString("\r\n\r\n", limit: 2)
          guard headerAndBody.count > 1 else { break }
          let header = headerAndBody[0]
          let body = headerAndBody[1]
          guard let decodedBody = Connection.decodeChunkedData(body) else { continue }
          let decodedData = NSMutableData()
          decodedData.appendData(header)
          decodedData.appendData(NSData(bytes: "\r\nContent-Length: \(decodedBody.length)\r\n\r\n".utf8))
          decodedData.appendData(decodedBody)
          request = Request(clientAddress: clientAddressString, data: decodedData)
          break
        }
        else {
          break
        }
      }
    }
    
    self.handler(request) {
      response in
      
      let responseData = response.data
      
      if response.chunked && response.bodyOnly {
        let length = NSString(format: "%x", responseData.length)
        let lengthData = NSData(bytes: "\(length)\r\n".utf8)
        Connection.write(connectionDescriptor, data: lengthData)
      }
      
      let bytesWritten = Connection.write(connectionDescriptor, data: responseData)
      
      if(bytesWritten == -1) {
        response.continuationCallback?(false)
        return
      }
      
      if response.chunked && response.bodyOnly {
        Connection.write(connectionDescriptor, data: NSData(bytes: "\r\n".utf8))
      }
      
      response.continuationCallback?(true)
      
      if !response.hasDefinedLength && responseData.length > 0 {
        return
      }
      
      if let startTime = startTime {
        let interval = Timestamp.now().epochSeconds - startTime.epochSeconds
        NSLog("Finished processing %@ in %lf seconds", request.path, interval)
      }
      if request.headers["Connection"] == "close" || response.headers["Connection"] == "close" {
        Connection.close(connectionDescriptor)
      }
      else if Connection.stubbing {
        self.readFromSocket(connectionDescriptor)
      }
      else {
        #if os(Linux)
          self.readFromSocket(connectionDescriptor)
        #else
        dispatch_async(Connection.dispatchQueue) {
          self.readFromSocket(connectionDescriptor)
        }
        #endif
      }
    }
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
    #if os(Linux)
    let socketDescriptor = socket(PF_INET, Int32(SOCK_STREAM.rawValue), Int32(IPPROTO_TCP))
    #else
    let socketDescriptor = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
    #endif
    let flag = [1]
    setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEADDR, flag, UInt32(sizeof(Int)))
    setsockopt(socketDescriptor, SOL_SOCKET, SO_KEEPALIVE, flag, UInt32(sizeof(Int)))
    
    if socketDescriptor == -1 {
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
    _ = Connection(fileDescriptor: socketDescriptor, handler: handler)
    
    NSLog("Listening on port %d", port)
    #if os(OSX)
    NSRunLoop.currentRunLoop().run()
    #endif

    return true
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

    - parameter connection:   The connection handle that we are reading from.
    - parameter buffer:       The buffer that we are reading into.
    - parameter maxLength:    The maximum size of the buffer.
    - returns:                The number of bytes that we actually read.
    */
  internal static func read(connection: Int32, buffer: UnsafeMutablePointer<Void>, maxLength: Int) -> Int {
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
  internal static func close(connection: Int32) {
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

    - parameter connection:   The connection to write to.
    - parameter data:         The data to write to the connection.
    - returns:                The number of bytes we wrote.
    */
  internal static func write(connection: Int32, data: NSData) -> Int {
    if stubbing {
      outputData.appendData(data)
      return data.length
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