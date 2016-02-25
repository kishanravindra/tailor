import Foundation

/**
  This protocol describes an HTTP message.
  */
public protocol HttpMessageType {
  /** The status line for the message. */
  var statusLine: String { get }

  /** The HTTP headers */
  var headers: [String: String] { get }

  /** The cookies */
  var cookies: CookieJar { get }

  /** The data from the body of the message. */
  var bodyData: NSData { get set }

  /**
    Whether the message is setting cookies (i.e. using the Set-Cookie header)
    or than receiving cookies (i.e. using the Cookie header).
    */
  var setsCookies: Bool { get }

  /**
    Whether this message has a pre-defined length.
    */
  var hasDefinedLength: Bool { get }

  /**
    Whether this message consists solely of a body, without any headers or
    status line.
    */
  var bodyOnly: Bool { get }

  /**
    This initializer creates the message from its constituent parts.

    - parameter statusLine:   The status line of the message.
    - parameter headers:      The HTTP headers.
    - parameter cookies:      The cookies
    - parameter bodyData:     The body of the message.
    */
  init(statusLine: String, headers: [String:String], cookies: CookieJar, bodyData: NSData)
}

extension HttpMessageType {
  /**
    This initializer creates a message from the raw data.

    This will extract the status line, headers, cookies, and body data from the
    message in accordance with the HTTP standard.

    - parameter data:   The full message data.
    */
  public init(data: NSData) {
    let headerAndBody = data.componentsSeparatedByString("\r\n\r\n", limit: 2)
    let headerData = headerAndBody[0]
    let bodyData: NSData
    if headerAndBody.count > 1 {
      bodyData = headerAndBody[1]
    }
    else {
      bodyData = NSData()
    }
    
    let headerString = NSString(data: headerData, encoding: NSUTF8StringEncoding) ?? ""
    
    var lines = headerString.componentsSeparatedByString("\r\n") as [String]
    let statusLine = lines.removeAtIndex(0)
    
    var headers : [String:String] = [:]
    var cookieHeaders = [String]()
    var cookies = CookieJar()
    var lastHeaderKey: String? = nil
    var lastWasCookie = false
    for index in 0..<lines.count {
      let line = lines[index]
      if line.isEmpty {
        continue
      }
      let continuationMatch = Request.extractWithPattern(line, pattern: "^[ \t]+(.*)$")
      if !continuationMatch.isEmpty {
        guard let key = lastHeaderKey else { continue }
        if lastWasCookie && cookieHeaders.count > 0 {
          cookieHeaders[cookieHeaders.endIndex.predecessor()] += " " + continuationMatch[0]
        }
        else {
          guard let value = headers[key] else { continue }
          headers[key] = value + " " + continuationMatch[0]
        }
      }
      let headerMatch = Request.extractWithPattern(line, pattern: "^([\\w-]*):[ \t]*(.*)$")
      
      if !headerMatch.isEmpty {
        if headerMatch[0] == "Cookie" {
          cookieHeaders.append(headerMatch[1])
          lastHeaderKey = headerMatch[1]
          lastWasCookie = true
        }
        else {
          headers[headerMatch[0]] = headerMatch[1]
          lastHeaderKey = headerMatch[0]
          lastWasCookie = false
        }
      }
    }
    
    for header in cookieHeaders {
      cookies.addHeaderString(header)
    }
    
    self.init(statusLine: statusLine, headers: headers, cookies: cookies, bodyData: bodyData)
  }

  //MARK: - Body Parsing
  
  /** The text of the request body. */
  public var bodyText : String { get {
    return NSString(data: self.bodyData, encoding: NSUTF8StringEncoding)?.bridge() ?? ""
  } }
  
  /**
    This method appends a string to the response.

    - parameter string:  The string to add
    */
  public mutating func appendString(string: String) {
    self.appendData(NSData(bytes: string.utf8))
  }
  
  /**
    This method appends raw data to the response.

    - parameter data:  The data to add.
    */
  public mutating func appendData(data: NSData) {
    let result = NSMutableData(data: self.bodyData)
    result.appendData(data)
    self.bodyData = result
  }

  /**
    This method removes all the data from the body.
    */
  public mutating func clearBody() {
    self.bodyData = NSData()
  }

  /** The full HTTP message data. */
  public var data: NSData {
    if bodyOnly { return self.bodyData }
    let data = NSMutableData()
    
    func add(string: String) {
      data.appendData(NSData(bytes: string.utf8))
    }
    
    add("\(statusLine)\r\n")
    
    var headers = self.headers
    
    if hasDefinedLength {
      headers["Content-Length"] = headers["Content-Length"] ?? String(bodyData.length)
    }
    
    headers["Content-Type"] = headers["Content-Type"] ?? "text/html; charset=UTF-8"
    headers["Date"] = headers["Date"] ?? Timestamp.now().inTimeZone("GMT").format(TimeFormat.Rfc822)
    
    for key in headers.keys.sort() {
      guard let value = headers[key] else { continue }
      add("\(key): \(value)\r\n")
    }
    if setsCookies {
      add(cookies.headerStringForChanges)
    }
    else {
      for cookie in cookies.cookies {
        add("Cookie: \(cookie.headerString)\r\n")
      }
    }
    add("\r\n")
    data.appendData(bodyData)
    return data
  }
}