import Foundation

/**
  This class represents a connection with a client.
  */
public class Connection : NSObject {
  /** The file descriptor that we are using to communicate with the client.*/
  let socketDescriptor: Int32
  
  /** A callback to the code to provide the request. */
  let handler: Server.RequestHandler
  
  /**
    This method creates a new connection.

    :param: fileDescriptor    The file descriptor for the socket that we are
                              using for the connection.
    :param: handler           A callback that will handle the request.
    */
  public required init(fileDescriptor: Int32, handler: Server.RequestHandler) {
    self.socketDescriptor = fileDescriptor
    self.handler = handler
    super.init()
    
    self.listenToSocket()
  }
  
  //MARK: - Handling Requests

  /**
    This method adds an operation to the main queue for getting a connection for
    our socket.
  
    This will return immediately after putting the operation in the queue.
  
    Once the connection is accepted, it will put an operation on a new
    queue for reading from the socket, and put an operation on the main queue
    for listening for a new connection.k
    */
  func listenToSocket() {
    NSOperationQueue.mainQueue().addOperationWithBlock {
      NSLog("Listening to %d", self.socketDescriptor)
      let connectionDescriptor = accept(self.socketDescriptor, nil, nil)
      NSLog("Connection descriptor: %d", connectionDescriptor)
      
      if connectionDescriptor < 0 {
        return
      }
      
      NSOperationQueue().addOperationWithBlock {
        self.readFromSocket(connectionDescriptor)
      }
      self.listenToSocket()
    }
  }
  
  /**
    This method reads the available data from a socket.
    
    It will read the data and process the request synchronosuly, then write the
    response data to the file descriptor and close it.
  
    :param: connectionDescriptor    The file descriptor for the connection.
    */
  func readFromSocket(connectionDescriptor: Int32) {
    var data = NSMutableData()
    var buffer = [UInt8]()
    let bufferLength: UInt = 1024
    
    for _ in 0..<bufferLength { buffer.append(0) }
    
    while true {
      let length = read(connectionDescriptor, &buffer, bufferLength)
      if length < 0 || length > Int(bufferLength) {
        close(connectionDescriptor)
        return
      }
      data.appendBytes(buffer, length: length)
      if length < Int(bufferLength) {
        break
      }
    }
    var clientAddress = sockaddr(
      sa_len: 0,
      sa_family: 0,
      sa_data: (0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    )
    var size = UInt32(sizeof(sockaddr))
    getpeername(connectionDescriptor, &clientAddress, &size)
    
    let clientAddressString = "\(clientAddress.sa_data.2).\(clientAddress.sa_data.3).\(clientAddress.sa_data.4).\(clientAddress.sa_data.5)"

    let request = Request(clientAddress: clientAddressString, data: data)
    self.handler(request) {
      let responseData = $0.data
      write(connectionDescriptor, responseData.bytes, UInt(responseData.length))
      close(connectionDescriptor)
      NSLog("Finished processing %@", request.path)
    }
  }
}