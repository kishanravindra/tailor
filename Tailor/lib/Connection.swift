import Foundation

/**
  This class represents a connection with a client.
  */
class Connection : NSObject {
  /** The handle that we are using to communicate with the client. */
  let listeningHandle : NSFileHandle
  
  /** A callback to the code to provide the request. */
  let handler: (Request,(Response)->())->()
  
  /**
    This method creates a new connection.

    :param: fileDescriptor    The file descriptor for the socket that we are
                              using for the connection.
    :param: handler           A callback that will handle the request.
    */
  required init(fileDescriptor: Int32, handler: (Request, (Response)->())->()) {
    self.listeningHandle = NSFileHandle(fileDescriptor: fileDescriptor, closeOnDealloc: false)
    self.handler = handler
    super.init()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionMade:"), name: NSFileHandleConnectionAcceptedNotification, object: listeningHandle)
    listeningHandle.acceptConnectionInBackgroundAndNotify()
  }
  
  //MARK: - Handling Requests
  
  /**
    This method is called when a client initiates a request.

    :param: notification    The notification from the file handle.
    */
  func connectionMade(notification: NSNotification) {
    let fileHandle = notification.userInfo![NSFileHandleNotificationFileHandleItem]! as NSFileHandle
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("dataAvailable:"), name:
      NSFileHandleDataAvailableNotification, object: fileHandle)
    fileHandle.waitForDataInBackgroundAndNotify()
  }
  
  /**
    This method is called when the client has data for us to process.
    
    :param: notification  The notification from the file handle.
    */
  func dataAvailable(notification: NSNotification) {
    listeningHandle.acceptConnectionInBackgroundAndNotify()
    let handle = notification.object! as NSFileHandle
    let request = Request(data: handle.availableData)
    handler(request, {
      handle.writeData($0.data)
    })
  }
}