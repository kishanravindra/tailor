/**
  This structure represents an email.

  It is responsible for capturing the information about an email and formatting
  it so that it can be given to an EmailDeliverer to send out.
  */
public struct Email: Equatable {
  /** The email address that is sending the message. */
  public let sender: String
  
  /** The email addresses that are receiving the message. */
  public let recipients: [String]
  
  /** The email addresses that are CCd on the message. */
  public let ccs: [String]
  
  /** The email addresses that are BCCd on the mesasge. */
  public let bccs: [String]
  
  /** The subject of the message. */
  public let subject: String
  
  /** The body of the message. */
  public let body: String
  
  /** The templates that this email has rendered. */
  public let renderedTemplates: [TemplateType]
  
  /**
    The full list of addresses that will recieve the message.

    This includes direct recipients, CCs, and BCCs.
    */
  public var allRecipients: [String] {
    return recipients + ccs + bccs
  }
  
  /** ASCII data for carriage return, line feed. */
  public static let newline = NSData(bytes: [13, 10])
  
  /** ASCII data for carriage return, line feed, space */
  public static let newlineWithSpace = NSData(bytes: [13, 10, 32])
  
  /** ASCII data for =?UTF-8?Q? */
  public static let headerQuotePrefix = NSData(bytes: [0x3D, 0x3F, 0x55, 0x54,
    0x46, 0x2D, 0x38, 0x3F, 0x51, 0x3F])
  
  /** ASCII data for ?= */
  public static let headerQuoteSuffix = NSData(bytes: [0x3F, 0x3D])
  
  /** The maximum length of a line in the encoded email data. */
  public static let maxLineLength = 78
  
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
  public init(from sender: String, to recipient: String? = nil, recipients: [String] = [], ccs: [String] = [], bccs: [String] = [], subject: String, body: String = "", var template: TemplateType? = nil) {
    self.sender = sender
    var recipients = recipients
    if let recipient = recipient {
      recipients.insert(recipient, atIndex: 0)
    }
    self.recipients = recipients
    self.ccs = ccs
    self.bccs = bccs
    self.subject = subject
    self.body = template?.generate() ?? body
    self.renderedTemplates = removeNils([template])
  }
  
  /**
    This method gets the full encoded message.
    */
  public var fullMessage: NSData {
    let messageData = NSMutableData()
    
    appendHeader(messageData, label: "From", value: sender)
    
    let recipientList = ",".join(recipients)
    appendHeader(messageData, label: "To", value: recipientList)
    
    if !ccs.isEmpty {
      let ccList = ",".join(ccs)
      appendHeader(messageData, label: "CC", value: ccList)
    }
    
    let date = Timestamp.now().format(TimeFormat.Rfc2822)
    appendHeader(messageData, label: "Date", value: date)
    
    appendHeader(messageData, label: "Content-Type", value: "text/html; charset=UTF-8")
    appendHeader(messageData, label: "Content-Transfer-Encoding", value: "quoted-printable")
    appendHeader(messageData, label: "Subject", value: subject)
    messageData.appendData(Email.newline)
    
    messageData.appendData(Email.encode(body))
    return messageData
  }
  
  /**
    This method appends a header a data buffer containing an email message.
  
    The value will be appropriate encoded and wrapped to be compliant with the
    spec.

    - parameter data:   The data buffer.
    - parameter label:  The label for the header. This MUST be an ASCII string.
                        The behavior of this with a non-ASCII label is
                        undefined.
    - parameter value:  The value for the header.
    */
  private func appendHeader(data: NSMutableData, label: String, value: String) {
    let fullHeader = label + ": " + value
    
    if let asciiData = fullHeader.dataUsingEncoding(NSASCIIStringEncoding) {
      if asciiData.length < Email.maxLineLength {
        data.appendData(asciiData)
        data.appendData(Email.newline)
        return
      }
    }
    let labelData = Email.encode(label + ": ")
    let encodedData = Email.encode(value, specialEscapes: [32,10,13,95,63], lineBreaker: [0x3F,0x3D,0x0D,0x0A,0x20,0x3D, 0x3F, 0x55, 0x54,
      0x46, 0x2D, 0x38, 0x3F, 0x51, 0x3F], initialLineLength: labelData.length + Email.headerQuotePrefix.length)
    data.appendData(labelData)
    data.appendData(Email.headerQuotePrefix)
    data.appendData(encodedData)
    data.appendData(Email.headerQuoteSuffix)
    data.appendData(Email.newline)
  }
  
  
  /**
    This method encodes text so that it can be put in an email message.
  
    This will use a UTF-8 encoding, filtered through the quoted-printable
    encoding. Any byte outside the printable ASCII characters will be encoded as
    an equal sign, followed by the hexadecimal representation of the byte value.
    This will also escape equal signs, and other special escaped characters
    specified in the second parameter.
  
    This will ensure that lines are kept to 76 characters, not including the
    terminating carriage return and line feed.
  
    - parameter string:               The text to encode
    - parameter specialEscapes        The printable ASCII characters that we
                                      should escape.
    - parameter lineBreaker:          The sequence of bytes to place between
                                      lines. This must contain exactly one
                                      sequence of 0x0D followed by 0x0A. If you
                                      do not provide such a sequence, the result
                                      of this will not be compliant with the
                                      spec and may not be accepted by the
                                      recipient. It is generally best to leave
                                      this with the default value.
    - parameter initialLineLength:    The number of characters in the first line
                                      prior to the beginning of this encoded
                                      string. Based on this value, we will break
                                      the first line early, to keep the full
                                      line at 76 characters.
    */
  public static func encode(string: String, specialEscapes: [UInt8] = [], lineBreaker: [UInt8] = [61,13,10], initialLineLength: Int = 0) -> NSData {
    var bytes = [UInt8]()
    var lineLength = initialLineLength
    let charactersBeforeNewline = (lineBreaker.indexOf(13) ?? lineBreaker.count)
    let charactersAfterNewline = lineBreaker.count - 1 - (lineBreaker.indexOf(10) ?? -1)
    for codeUnit in string.utf8 {
      if codeUnit == 10 && !specialEscapes.contains(codeUnit) {
        if bytes[bytes.count - 1] == 32 {
          bytes[bytes.count - 1] = 61
          bytes.append(50)
          bytes.append(48)
        }
        bytes.append(13)
        bytes.append(10)
        lineLength = 0
      }
      else if codeUnit == 13 && !specialEscapes.contains(codeUnit) {
      }
      else if codeUnit > 126 || codeUnit < 32 || codeUnit == 61 || specialEscapes.contains(codeUnit) {
        if lineLength >= Email.maxLineLength - charactersBeforeNewline - 5 {
          bytes.extend(lineBreaker)
          lineLength = charactersAfterNewline
        }
        bytes.append(61)
        let topNybble = codeUnit / 16
        let bottomNybble = codeUnit % 16
        bytes.append(topNybble + (topNybble > 9 ? 55 : 48))
        bytes.append(bottomNybble + (bottomNybble > 9 ? 55 : 48))
        lineLength += 3
      }
      else {
        if lineLength >= Email.maxLineLength - charactersBeforeNewline - 2 {
          bytes.extend(lineBreaker)
          lineLength = charactersAfterNewline
        }
        bytes.append(codeUnit)
        lineLength += 1
      }
    }
    let data = NSData(bytes: bytes)
    return data
  }
  
  /**
    This method delivers the email using the shared email agent.
  
    You can get the shared email agent directly by calling
    `Application.sharedEmailAgent`.
    */
  public func deliver() {
    Application.sharedEmailAgent().deliver(self)
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
    lhs.sender == rhs.sender &&
    lhs.recipients == rhs.recipients &&
    lhs.subject == rhs.subject
}