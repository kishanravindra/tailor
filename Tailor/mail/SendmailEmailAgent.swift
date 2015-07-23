/**
  This class provides an email agent for sending mail using sendmail.

  This assumes that you have sendmail defined at `/usr/sbin/sendmail`. If you
  don't, this will cause a fatal error.
  */
public final class SendmailEmailAgent: EmailAgent {
  /**
    This initializer creates a sendmail agent.

    - parameter config:   The application's mail config.
    */
  public init(_ config: [String: String]) {
  }
  
  
  /**
    This method delivers an email with sendmail.

    This will run a sendmail command andfeed it the email over its standard
    input.
    
    - parameter email:    The email to deliver.
    */
  public func deliver(email: Email) {
    let process = ExternalProcess(launchPath: "/usr/sbin/sendmail", arguments: ["-bs"])
    process.launch()

    for recipient in email.allRecipients {
      process.writeString("MAIL FROM: \(email.sender)\r\n")
      process.writeString("RCPT TO: \(recipient)\r\n")
      process.writeString("DATA\r\n")
      process.writeData(email.fullMessage)
      process.writeString("\r\n.\r\n")
    }
  }
}