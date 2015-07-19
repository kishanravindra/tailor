/**
  This class provides an email delivery system that stores the messages in a
  local file.

  This is good for local development environments, where sending out emails to
  real email addresses is likely undesireable. It is the default delivery
  system.
  */
public final class FileEmailAgent: EmailAgent {
  /** The path to the file where this agent will store the email contents. */
  public let path: String
  
  /**
    This initializer creates an email deliverer from the application
    configuration.

    This looks for the following configuration settings:

    * +path+: The path to the file to store the emails in.

    - parameter config: The application configuration
    */
  public init(_ config: [String:String]) {
    self.path = config["path"] ?? "/tmp/mail.txt"
  }
  
  /**
    This enum captures the errors that can be thrown when deliverying email.
    */
  public enum Errors: ErrorType {
    /** An error creating the stream. */
    case ErrorOpeningFile
    
    /** An unknown error writing to the stream. */
    case ErrorWritingToFile
  }
  
  /**
    This method delivers an email.
  
    This can throw 
    - parameter email:    The email to deliver.
    */
  public func deliver(email: Email) throws {
    let contents = email.fullMessage
    let data = contents.dataUsingEncoding(NSASCIIStringEncoding)!
    guard let stream = NSOutputStream(toFileAtPath: self.path, append: true) else {
      throw Errors.ErrorOpeningFile
    }
    var bytesWritten = 0
    let buffer = UnsafePointer<UInt8>(data.bytes)
    stream.open()
    while bytesWritten < data.length {
      let newBytes = stream.write(buffer, maxLength: data.length - bytesWritten)
      if newBytes == -1 {
        if let error = stream.streamError {
          throw error
        }
        else {
          throw Errors.ErrorWritingToFile
        }
      }
      bytesWritten += newBytes
      advance(buffer, bytesWritten)
    }
    var closingBytes: [UInt8] = [13, 10]
    stream.write(&closingBytes, maxLength: 2)
    stream.close()
  }
}
