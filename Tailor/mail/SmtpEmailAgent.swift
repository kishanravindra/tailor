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
    This method delivers an email via SMTP.

    This will use curl to connect to the server. You must have curl installed in
    /usr/bin/curl.

    The delivery will be done asynchronously.

    - parameter email:      The email that we are sending.
    - parameter callback:   A callback to call with the result of trying to
                            deliver the message.
    */
  public func deliver(email: Email, callback: Email.ResultHandler) {
    for recipient in email.allRecipients {
      let arguments =  [
        "smtps://\(host)",
        "--mail-from",
        email.sender,
        "--mail-rcpt",
        recipient,
        "--ssl",
        "-u",
        "\(username):\(password)",
        "-T",
        "-"
      ]
      let process = ExternalProcess(launchPath: "/usr/bin/curl", arguments: arguments) {
        terminationStatus, data in
        
        let fullResponse = NSString(data: data, encoding: NSUTF8StringEncoding) as? String ?? ""
        let lastLine = fullResponse.lastComponent(separator: "curl:")
        if terminationStatus == 0 {
          callback(success: true, code: terminationStatus, message: "")
        }
        else {
          callback(success: false, code: terminationStatus, message: lastLine)
        }
      }
      process.launch()
      
      process.writeData(email.fullMessage)
      process.closeInput()
    }
  }
}