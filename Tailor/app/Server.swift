import Foundation

/**
  This class provides an HTTP server.
  */
class Server {
  /** A callback that can be given a response. */
  typealias ResponseCallback = (Response)->()
  
  /** A closure that can process a request. */
  typealias RequestHandler = (Request, ResponseCallback)->()
  
  /** The connection that the server is listening on. */
  private(set) var connection: Connection?

  /**
    This method initializes the server.
    */
  required init() {
    
  }
  
  //MARK - Running

  /**
    This method starts the server.

    It will open the connection and then tell the run loop to run indefinitely.

    :param: address   The IP address to listen on.
    :param: port      The port to listen on.
    :param: handler   A callback that will be called when a request is ready for
                      processing. This will be given a request and another
                      callback that it can call with a response.
  
    :returns:         Whether we were able to open the connection.
    */
  func start(address: (Int,Int,Int,Int), port: Int, handler: RequestHandler) -> Bool {
    let socketDescriptor = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
    let flag = [1]
    setsockopt(socketDescriptor, SOL_SOCKET, SO_REUSEADDR, flag, UInt32(sizeof(Int)))
    setsockopt(socketDescriptor, SOL_SOCKET, SO_KEEPALIVE, flag, UInt32(sizeof(Int)))
    
    if socketDescriptor == -1 {
      NSLog("Error creating socket")
      return false
    }
    var socketAddress = createSocketAddress(Int32(port))
    
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
    
    self.connection = Connection(fileDescriptor: socketDescriptor, handler: handler)
    
    NSLog("Listening on port %d", port)
    
    NSRunLoop.currentRunLoop().run()
    return true
  }
}