import Foundation
#if os(Linux)
  import Glibc
#endif

/**
  This structure represents an email.

  It is responsible for capturing the information about an email and formatting
  it so that it can be given to an EmailDeliverer to send out.

  NOTE: This system does not do any validation on the data in the email address
  fields. It will be passed directly to the email agent. If any of the address
  sections (sender, recipients, ccs, bccs) contains non-ASCII data, that entire
  section may be encoded in a way that causes them to get rejected by their
  recipients.
  */
public struct Email: Equatable {
  /**
    A handler for processing results from the email agent.
  
    - parameter success:    Whether the email was sent successfully.
    - parameter code:       An error code identifying the problem.
    - parameter message:    An error message describing the problem sending the
                            email.
    */
  public typealias ResultHandler = (success: Bool, code: Int, message: String)->Void
  
  /**
    This structure represents an attachment to an email.
    */
  public struct Attachment: Equatable {
    /** The MIME type for the file. */
    public let type: String
    
    /** The name for the file. */
    public let filename: String
    
    /** The contents of the file. */
    public let data: NSData
    
    /**
      This initializer creates an email attachment.

      - parameter type:       The MIME type for the file.
      - parameter filename:   The name for the file.
      - parameter data:       The contents of the file.
      */
    public init(type: String, filename: String, data: NSData) {
      self.type = type
      self.filename = filename
      self.data = data
    }
  }
  
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
  
  /** ASCII data for -- */
  public static let boundaryMarker = NSData(bytes: [0x2D, 0x2D])
  
  /** The maximum length of a line in the encoded email data. */
  public static let maxLineLength = 78
  
  /** The attachments to the email. */
  public var attachments: [Attachment]
  
  /**
    This initializer creates an email.

    - parameter from:       The email address that is sending the message.
    - parameter to:         The email address that is receiving the message.
    - parameter subject:    The subject line of the message.
    - parameter body:       The body of the message.
    - parameter template:   The template that we should render to provide the
                            body. If this is provided, the body parameter is
                            ignored.
    - parameter attachments:    The attachments to the email.
    */
  public init(from sender: String, to recipient: String? = nil, recipients: [String] = [], ccs: [String] = [], bccs: [String] = [], subject: String, body: String = "", template: TemplateType? = nil, attachments: [Attachment] = []) {
    self.sender = sender
    var recipients = recipients
    if let recipient = recipient {
      recipients.insert(recipient, atIndex: 0)
    }
    self.recipients = recipients
    self.ccs = ccs
    self.bccs = bccs
    self.subject = subject
    
    var renderedTemplate = template
    self.body = renderedTemplate?.generate() ?? body
    self.renderedTemplates = [renderedTemplate].flatMap { $0 }
    self.attachments = attachments
  }
  
  /**
    This method gets the message data for the body text, including the content
    headers.
    
    - returns:  The data.
    */
  private func bodyMessageData() -> NSData {
    let data = NSMutableData()
    appendHeader(data, label: "Content-Type", value: "text/html; charset=UTF-8")
    appendHeader(data, label: "Content-Transfer-Encoding", value: "quoted-printable")
    data.appendData(Email.newline)
    data.appendData(Email.encode(body))
    return data
  }
  
  /**
    This method gets the message data for an attachment, including the content
    headers.

    - returns:  The data
    */
  private func attachmentMessageData(attachment: Attachment) -> NSData {
    let data = NSMutableData()
    appendHeader(data, label: "Content-Type", value: attachment.type)
    appendHeader(data, label: "Content-Transfer-Encoding", value: "base64")
    appendHeader(data, label: "Content-Disposition", value: "attachment; filename=\"\(attachment.filename)\"")
    data.appendData(Email.newline)
    data.appendData(attachment.data.base64EncodedDataWithOptions([.Encoding76CharacterLineLength]))
    return data
  }
  
  /**
    This method creates a boundary for separating components in a message body.

    The boundary will start with a lowercase b and will not appear anywhere in
    any of the components.
    */
  private func createBoundary(components: [NSData]) -> NSData {
    let boundary = NSMutableData(bytes: [0x62])
    while true {
      for component in components {
        let range = component.rangeOfData(component, options: [], range: NSMakeRange(0, component.length))
        if range.location != NSNotFound {
          var newByte = 0x30 + rand() % 66
          if newByte > 0x39 {
            newByte += 6
          }
          if newByte > 0x5A {
            newByte += 6
          }
          boundary.appendBytes(&newByte, length: 1)
          continue
        }
      }
      break
    }
    return boundary
  }
  
  /**
    This method gets a multipart message body.

    - parameter components:   The data for the parts of the multipart body.
    - parameter type:         The sub-content-type for the multipart entity.
                              This does not include the "multipart" prefix, so
                              for a content-type of multipart/mixed, this should
                              be mixed.
    - returns:                The full multipart data, including the outer
                              headers and the components themselves.
    */
  private func multipartMessageData(components: [NSData], type: String) -> NSData {
    let data = NSMutableData()
    let boundary = createBoundary(components)
    guard let boundaryString = NSString(data: boundary, encoding: NSASCIIStringEncoding) else {
      fatalError("Email boundary is statically guaranteed to be ASCII-safe, but could not be encoded")
    }
    appendHeader(data, label: "Content-Type", value: "multipart/\(type); boundary=\"\(boundaryString)\"")
    data.appendData(Email.newline)
    for component in components {
      data.appendData(Email.boundaryMarker)
      data.appendData(boundary)
      data.appendData(Email.newline)
      data.appendData(component)
      data.appendData(Email.newline)
    }
    data.appendData(Email.boundaryMarker)
    data.appendData(boundary)
    data.appendData(Email.boundaryMarker)
    return data
  }
  
  /**
    This method gets the full encoded message.
    */
  public var fullMessage: NSData {
    let messageData = NSMutableData()
    
    appendHeader(messageData, label: "From", value: sender)
    
    let recipientList = recipients.joinWithSeparator(",")
    appendHeader(messageData, label: "To", value: recipientList)
    
    if !ccs.isEmpty {
      let ccList = ccs.joinWithSeparator(",")
      appendHeader(messageData, label: "CC", value: ccList)
    }
    
    let date = Timestamp.now().format(TimeFormat.Rfc2822)
    appendHeader(messageData, label: "Date", value: date)
    
    appendHeader(messageData, label: "Subject", value: subject)
    
    if attachments.isEmpty {
      messageData.appendData(self.bodyMessageData())
    }
    else {
      let components = [self.bodyMessageData()] + attachments.map { self.attachmentMessageData($0) }
      messageData.appendData(multipartMessageData(components, type: "mixed"))
    }
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
    
    if let asciiData = fullHeader.bridge().dataUsingEncoding(NSASCIIStringEncoding) {
      if asciiData.length < Email.maxLineLength || label != "Subject" {
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
          bytes.appendContentsOf(lineBreaker)
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
          bytes.appendContentsOf(lineBreaker)
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
    
    - parameter callback:   A callback that will be called with the result of
                            sending the email. If this is not provided, we will
                            log any failures and ignore any successes.
    */
  public func deliver(callback: ResultHandler? = nil) {
    let agent = Application.sharedEmailAgent()
    if let callback = callback {
      agent.deliver(self, callback: callback)
    }
    else {
      agent.deliver(self) {
        (success: Bool, code: Int, message: String)->Void in
        if success == false {
          NSLog("Error delivering email: \(code) \(message)")
        }
      }
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
    lhs.sender == rhs.sender &&
    lhs.recipients == rhs.recipients &&
    lhs.subject == rhs.subject
}

/**
  This method determines if two email attachments are equal.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two email attachments are equal.
  */
public func ==(lhs: Email.Attachment, rhs: Email.Attachment) -> Bool {
  return lhs.type == rhs.type && lhs.filename == rhs.filename && lhs.data == rhs.data
}