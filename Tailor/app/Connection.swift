import Foundation

/**
  This class represents a connection with a client.
  */
public struct Connection {
  
  /** A callback that can be given a response. */
  public typealias ResponseCallback = (Response)->()
  
  /** A closure that can process a request. */
  public typealias RequestHandler = (Request, ResponseCallback)->()
  
  /** The file descriptor that we are using to communicate with the client.*/
  let socketDescriptor: Int32
  
  /** A callback to the code to provide the request. */
  let handler: RequestHandler
  
  /** The queue that we put requests on. */
  public static let dispatchQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
  
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
    NSOperationQueue.mainQueue().addOperationWithBlock {
      let connectionDescriptor = accept(self.socketDescriptor, nil, nil)
      
      if connectionDescriptor < 0 {
        return
      }
      
      dispatch_async(Connection.dispatchQueue) {
        self.readFromSocket(connectionDescriptor)
      }
      self.listenToSocket()
    }
  }
  
  /**
    This method reads the available data from a socket.
    
    It will read the data and process the request synchronosuly, then write the
    response data to the file descriptor and close it.
  
    - parameter connectionDescriptor:    The file descriptor for the connection.
    */
  public mutating func readFromSocket(connectionDescriptor: Int32) {
    let data = NSMutableData()
    let bufferLength: UInt = 1024
    var buffer = [UInt8](count: Int(bufferLength), repeatedValue: 0)
    var request: Request!
    let startTime = Timestamp.now()
    
    var clientAddress = sockaddr(
      sa_len: 0,
      sa_family: 0,
      sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    )
    
    let clientAddressString = "\(clientAddress.sa_data.2).\(clientAddress.sa_data.3).\(clientAddress.sa_data.4).\(clientAddress.sa_data.5)"
    
    var size = UInt32(sizeof(sockaddr))
    getpeername(connectionDescriptor, &clientAddress, &size)
    while true {
      let length = read(connectionDescriptor, &buffer, Int(bufferLength))
      if length < 0 || length > Int(bufferLength) {
        close(connectionDescriptor)
        return
      }
      data.appendBytes(buffer, length: length)
      if UInt(length) < bufferLength {
        request = Request(clientAddress: clientAddressString, data: data)
        let headerLength = Int(request.headers["Content-Length"] ?? "") ?? 0
        if request.body.length == headerLength {
          break
        }
      }
    }
    
    self.handler(request) {
      let responseData = $0.data
      write(connectionDescriptor, responseData.bytes, responseData.length)
      close(connectionDescriptor)
      let interval = Timestamp.now().epochSeconds - startTime.epochSeconds
      NSLog("Finished processing %@ in %lf seconds", request.path, interval)
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
    let socketDescriptor = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
    let flag = [1]
    setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEADDR, flag, UInt32(sizeof(Int)))
    setsockopt(socketDescriptor, SOL_SOCKET, SO_KEEPALIVE, flag, UInt32(sizeof(Int)))
    
    if socketDescriptor == -1 {
      NSLog("Error creating socket")
      return false
    }
    
    var socketAddress = sockaddr_in()
    socketAddress.sin_family = UInt8(AF_INET)
    socketAddress.sin_port = CFSwapInt16(UInt16(port))
    
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
    
    Connection(fileDescriptor: socketDescriptor, handler: handler)
    
    NSLog("Listening on port %d", port)
    
    NSRunLoop.currentRunLoop().run()
    return true
  }
}