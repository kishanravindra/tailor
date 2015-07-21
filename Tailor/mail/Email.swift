/**
  This structure represents an email.

  It is responsible for capturing the information about an email and formatting
  it so that it can be given to an EmailDeliverer to send out.
  */
public struct Email: Equatable {
  /** The email address that is sending the message. */
  public let from: String
  
  /** The email address that is receiving the message. */
  public let to: String
  
  /** The subject of the message. */
  public let subject: String
  
  /** The body of the message. */
  public let body: String
  
  /** The templates that this email has rendered. */
  public let renderedTemplates: [TemplateType]
  
  /**
    This initializer creates an email.

    - parameter from:       The email address that is sending the message.
    - parameter to:         The email address that is receiving the message.
    - parameter subject:    The subject line of the message.
    - parameter body:       The body of the message.
    - parameter template:   The template that we should render to provide the
                            body. If this is provided, the body parameter is
                            ignored.
    */
  public init(from: String, to: String, subject: String, body: String = "", var template: TemplateType? = nil) {
    self.from = from
    self.to = to
    self.subject = subject
    self.body = template?.generate() ?? body
    self.renderedTemplates = removeNils([template])
  }
  
  /**
    This method gets the full encoded message.
    */
  public var fullMessage: NSData {
    var message = ""
    message += "From: \(from)\r\n"
    message += "To: \(to)\r\n"
    
    let date = Timestamp.now().format(TimeFormat.Rfc2822)
    message += "Date: \(date)\r\n"
    message += "Content-Type: text/html; charset=UTF-8\r\n"
    message += "Content-Transfer-Encoding: quoted-printable\r\n"
    message += "Subject: \(subject)\r\n"
    message += "\r\n"
    
    let messageData = NSMutableData()
    messageData.appendData(message.dataUsingEncoding(NSASCIIStringEncoding) ?? NSData())
    messageData.appendData(Email.encode(body))
    return messageData
  }
  
  /**
    This method encodes text so that it can be put in an email message.
  
    This will use the quoted-printable encoding.
    */
  public static func encode(string: String) -> NSData {
    var bytes = [UInt8]()
    var inEscape = false
    var lineLength = 0
    for codeUnit in string.utf8 {
      if codeUnit == 10 {
        if bytes[bytes.count - 1] == 32 {
          bytes[bytes.count - 1] = 61
          bytes.append(50)
          bytes.append(48)
        }
        bytes.append(13)
        bytes.append(10)
        lineLength = 0
      }
      else if codeUnit == 13 {
      }
      else if codeUnit > 126 || codeUnit < 32 || codeUnit == 61 {
        if !inEscape {
          bytes.append(61)
          lineLength += 1
        }
        let topNybble = codeUnit / 16
        let bottomNybble = codeUnit % 16
        bytes.append(topNybble + (topNybble > 9 ? 55 : 48))
        bytes.append(bottomNybble + (bottomNybble > 9 ? 55 : 48))
        lineLength += 2
      }
      else {
        bytes.append(codeUnit)
        lineLength += 1
        inEscape = false
      }
      if lineLength == 75 {
        bytes.append(61)
        bytes.append(13)
        bytes.append(10)
        lineLength = 0
      }
    }
    let data = NSData(bytes: bytes)
    return data
  }
  
  /**
    This method delivers the email using the shared email agent.

    This will catch any errors thrown by the email agent and log them rather
    than handling or rethrowing them. If you want to be able to catch these
    errors, you should use the deliver method on the email agent instead of
    this method.
  
    You can get the shared email agent directly by calling
    `Application.sharedEmailAgent`.
    */
  public func deliver() {
    do {
      try Application.sharedEmailAgent().deliver(self)
    }
    catch let error {
      NSLog("Error delivering email\n%@: %d\n%@",error._domain, error._code, self.fullMessage)
    }
  }
}

/**
  This method determines if two emails are equal.

  Emails are equal if they have the same subject, body, sender, and recipients.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two emails are equal.
  */
public func ==(lhs: Email, rhs: Email) -> Bool {
  return lhs.subject == rhs.subject &&
    lhs.body == rhs.body &&
    lhs.to == rhs.to &&
    lhs.from == rhs.from
}