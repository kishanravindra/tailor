/**
  This class provides an email agent for sending mail using sendmail.

  This assumes that you have sendmail defined at `/usr/sbin/sendmail`. If you
  don't, this will cause a fatal error.
  */
public struct SendmailEmailAgent: EmailAgent {
  /**
    This initializer creates an email agent.
    */
  public init() {
  }

  /**
    This method delivers an email with sendmail.

    This will run a sendmail command andfeed it the email over its standard
    input.
    
    - parameter email:      The email to deliver.
    - parameter callback:   A callback to call with the result of trying to
                            deliver the email.
    */
  public func deliver(email: Email, callback: Email.ResultHandler) {
    let process = ExternalProcess(launchPath: "/usr/sbin/sendmail", arguments: ["-bs"]) {
      code, data in
      let response = NSString(data: data, encoding: NSUTF8StringEncoding) as? String ?? ""
      let lastLine = response.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) .lastComponent(separator: "\n")
      let success = lastLine.hasPrefix("250")
      callback(success: success, code: (success ? 0 : 1), message: response)
    }
    process.launch()

    for recipient in email.allRecipients {
      process.writeString("MAIL FROM: \(email.sender)\r\n")
      process.writeString("RCPT TO: \(recipient)\r\n")
      process.writeString("DATA\r\n")
      process.writeData(email.fullMessage)
      process.writeString("\r\n.\r\n")
    }
    process.closeInput()
  }
}