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
    guard let stream = NSOutputStream(toFileAtPath: self.path, append: true) else {
      callback(success: false, code: 1, message: "Error opening email file")
      return
    }
    var bytesWritten = 0
    let buffer = UnsafePointer<UInt8>(data.bytes)
    stream.open()
    while bytesWritten < data.length {
      let newBytes = stream.write(buffer, maxLength: data.length - bytesWritten)
      if newBytes == -1 {
        callback(success: false, code: 1, message: "Error writing to email file")
        return
      }
      bytesWritten += newBytes
      advance(buffer, bytesWritten)
    }
    var closingBytes: [UInt8] = [13, 10]
    stream.write(&closingBytes, maxLength: 2)
    stream.close()
    callback(success: true, code: 0, message: "")
  }
}
