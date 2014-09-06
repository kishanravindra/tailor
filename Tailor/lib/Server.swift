import Foundation

/**
  This class provides an HTTP server.
  */
class Server {
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
  func start(address: (Int,Int,Int,Int), port: Int, handler: (Request, (Response)->())->()) -> Bool {
    let socket = CFSocketCreate(nil, 0, 0, 0, 0, nil, nil)
    
    let fileDescriptor = CFSocketGetNative(socket)
    
    setsockopt(fileDescriptor, SOL_SOCKET, SO_REUSEADDR, nil, UInt32(sizeof(Int)))
    
    let length = UInt8(sizeof(sockaddr_in))
    let ipAddress = address.3 << 24 + address.2 << 16 + address.1 << 8 + address.0
    let convertedPort = UInt16(port >> 8 | (port & 255) << 8)
    
    var socketAddress = sockaddr_in(
      sin_len: length,
      sin_family: UInt8(AF_INET),
      sin_port: convertedPort,
      sin_addr: in_addr(
        s_addr: UInt32(ipAddress)
      ),
      sin_zero: (0,0,0,0,0,0,0,0)
    )
    
    let addressResult = withUnsafePointer(&socketAddress, {
      (pointer: UnsafePointer) -> CFSocketError in
      let intPointer = UnsafePointer<UInt8>(pointer)
      let data = CFDataCreate(nil, intPointer, sizeof(sockaddr_in))
      return CFSocketSetAddress(socket, data)
    })
    
    if addressResult != CFSocketError.Success {
      NSLog("Error opening socket")
      return false
    }
    
    self.connection = Connection(fileDescriptor: fileDescriptor, handler: handler)
    NSLog("Listening on port %d", port)
    NSRunLoop.currentRunLoop().run()
    return true
  }
}