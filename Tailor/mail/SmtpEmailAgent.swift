/**
  This class provides an agent for delivering email via SMTP.
  */
public final class SmtpEmailAgent: EmailAgent {
  /** The sender's email host. */
  public let host: String
  
  /** The sender's username. */
  public let username: String
  
  /** The sender's password. */
  public let password: String
  
  /** The port that the email host accepts connections on. */
  public let port: Int
  
  /** Whether the connection will be sent over SMTP. */
  public let ssl: Bool
  
  /**
    This initializer creates an SMTP email agent.

    This accepts the following config keys:

    - host: The sender's email host. The default is an empty string.
    - username: The sender's username. The default is an empty string.
    - password: The sender's password. The default is an empty string.
    - ssl: Whether to connect over ssl. This must be either "true" or "false".
    - port: The port to connect on. The default is 465 for SSL connections and
      587 for non-SSL connections.

    - parameter config:   The application's email configuration.
    */
  public init(_ config: [String:String]) {
    host = config["host"] ?? ""
    username = config["username"] ?? ""
    password = config["password"] ?? ""
    let ssl = config["ssl"] ?? "true" == "true"
    self.ssl = ssl
    port = Int(config["port"] ?? "") ?? (ssl ? 465 : 587)
  }
  
  /**
    This method gets the arguments that we pass to curl when delivering emails.

    - parameter email:    The email that we are sending.
    - returns:            The parameters that we will pass to curl.
    */
  internal func curlArguments(email: Email) -> [String] {
    return [
      "smtps://\(host)",
      "--mail-from",
      email.from,
      "--mail-rcpt",
      email.to,
      "--ssl",
      "-u",
      "\(username):\(password)",
      "-T",
      "-"
    ]
  }
  
  /**
    This method delivers an email via SMTP.

    This will use curl to connect to the server. You must have curl installed in
    /usr/bin/curl.

    The delivery will be done asynchronously. Any errors will be logged to the
    standard log.

    - parameter email:    The email that we are sending.
    */
  public func deliver(email: Email) {
    let task = NSTask()
    task.launchPath = "/usr/bin/curl"
    task.arguments = self.curlArguments(email)
    let input = NSPipe()
    let output = NSPipe()
    task.standardInput = input
    task.standardOutput = output
    task.standardError = output
    task.launch()
    
    input.fileHandleForWriting.writeData(email.fullMessage)
    input.fileHandleForWriting.writeData(NSData(bytes: [13, 10, 46, 13, 10]))
    input.fileHandleForWriting.closeFile()
    
    task.terminationHandler = {
      task in
      if task.terminationStatus != 0 {
        let data = output.fileHandleForReading.availableData.componentsSeparatedByString("curl:").last ?? NSData()
        let response = NSString(data: data, encoding: NSASCIIStringEncoding) ?? ""
        NSLog("Error sending email via SMTP: %@", response)
      }
    }
  }
}