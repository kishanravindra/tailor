import Foundation

/**
  This class provides an email delivery system that stores the messages in a
  local file.

  This is good for local development environments, where sending out emails to
  real email addresses is likely undesireable. It is the default delivery
  system.
  */
public struct FileEmailAgent: EmailAgent {
  /** The path to the file where this agent will store the email contents. */
  public let path: String
  
  /**
    This initializer creates an email agent for storing emails in a file.
  
    - parameter path: The path to the file to store the emails in.
    */
  public init(path: String = "/tmp/mail.txt") {
    self.path = path
  }
  
  /**
    This method delivers an email.
  
    - parameter email:    The email to deliver.
    */
  public func deliver(email: Email, callback: Email.ResultHandler) {
    let data = email.fullMessage
    
    if !NSFileManager.defaultManager().fileExistsAtPath(self.path) {
      guard NSFileManager.defaultManager().createFileAtPath(self.path, contents: nil, attributes: nil) else {
        callback(success: false, code: 1, message: "Error opening email file")
        return
      }
    }
    guard let handle = NSFileHandle(forUpdatingAtPath: self.path) else {
      callback(success: false, code: 1, message: "Error opening email file")
      return
    }
    handle.seekToEndOfFile()
    handle.writeData(data)
    handle.writeData(NSData(bytes: [13, 10]))
    handle.closeFile()
    callback(success: true, code: 0, message: "")
  }
}
