import Foundation

/**
  This class represents a request from the client.
  */
public struct Request: Equatable {
  /** The client's IP address. */
  public let clientAddress: String
  
  /** The full request data. */
  public let data: NSData
  
  /** The HTTP method. */
  public let method: String
  
  /** The HTTP version */
  public let version: String
  
  /** The full path from the request. */
  public let fullPath: String
  
  /** The path that the client is requesting, without the query string. */
  public let path: String
  
  /** The header information from the request. */
  public let headers: [String: String]
  
  /** The full request data. */
  public let body: NSData
  
  /** The request parameters. */
  public var requestParameters: [String:String] = [:]
  
  /**
    The files that were uploaded in this request.

    This will map the parameter name for the file to a hash containing the 
    contentType and the data.
  */
  public var uploadedFiles: [String:[String:Any]] = [:]
  
  /** The cookies that were sent with this request. */
  public let cookies: CookieJar
  
  /**
    This method initializes a request.

    - parameter clientAddress:   The client's IP address.
    - parameter data:            The full request data.
    */
  public init(clientAddress: String, data: NSData) {
    self.clientAddress = clientAddress
    self.data = data
    
    let headerAndBody = data.componentsSeparatedByString("\r\n\r\n", limit: 2)
    let headerData = headerAndBody[0]
    if headerAndBody.count > 1 {
      self.body = headerAndBody[1]
    }
    else {
      self.body = NSData()
    }
    
    let headerString = NSString(data: headerData, encoding: NSUTF8StringEncoding) ?? ""
    
    var lines = headerString.componentsSeparatedByString("\r\n") as [String]
    let introMatches = Request.extractWithPattern(lines[0], pattern: "^([\\S]*) ([\\S]*) HTTP/([\\d.]*)$")
    
    if introMatches.isEmpty {
      self.method = "GET"
      self.version = "1.1"
      self.fullPath = "/"
    }
    else {
      self.method = introMatches[0]
      self.version = introMatches[2]
      self.fullPath = introMatches[1]
      lines.removeAtIndex(0)
    }
    
    if let queryStringLocation = self.fullPath.rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch) {
      self.path = self.fullPath.substringToIndex(queryStringLocation.startIndex)
    }
    else {
      self.path = self.fullPath
    }
    
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
    self.headers = headers
    
    for header in cookieHeaders {
      cookies.addHeaderString(header)
    }
    
    self.cookies = cookies
    
    self.parseRequestParameters()
  }
  
  //MARK: - Body Parsing
  
  /** The text of the request body. */
  public var bodyText : String { get {
    return (NSString(data: self.body, encoding: NSUTF8StringEncoding) as? String) ?? ""
  } }
  
  /**
    This method extracts the request parameters from the query string and the
    request body.
    */
  private mutating func parseRequestParameters() {
    if let queryStringLocation = self.fullPath.rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch) {
      let queryString = self.fullPath.substringFromIndex(queryStringLocation.startIndex.successor())
      for (key, value) in Request.decodeQueryString(queryString) {
        self.requestParameters[key] = value
      }
    }
    
    if let contentType = headers["Content-Type"] {
      if  contentType == "application/x-www-form-urlencoded" {
        for (key,value) in Request.decodeQueryString(self.bodyText) {
          self.requestParameters[key] = value
        }
      }
      if contentType.hasPrefix("multipart/form-data") {
        self.parseMultipartForm()
      }
    }
  }
  
  /**
    This method extracts request parameters and uploaded files from a multitype
    form.
    */
  private mutating func parseMultipartForm() {
    guard let contentType = headers["Content-Type"] else { return }
    
    let boundaryComponents = contentType.componentsSeparatedByString("boundary=")
    guard boundaryComponents.count > 1 else { return }
    
    let boundary = boundaryComponents[1]
    let components = self.body.componentsSeparatedByString("--\(boundary)")
    for component in components {
      if component.length <= 4 {
        continue
      }
      let trimmedData = component.subdataWithRange(NSRange(location: 2, length: component.length - 4))
      let subRequest = Request(clientAddress: self.clientAddress, data: trimmedData)
      
      var parameterName : String? = nil
      
      if let disposition = subRequest.headers["Content-Disposition"] {
        for dispositionComponent in disposition.componentsSeparatedByString("; ") {
          if dispositionComponent.hasPrefix("name=") {
            parameterName = dispositionComponent.substringFromIndex(advance(dispositionComponent.startIndex, 5)).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
          }
        }
      }
      
      guard let name = parameterName else { continue }
      
      if let contentType = subRequest.headers["Content-Type"] {
        self.uploadedFiles[name] = [
          "contentType": contentType,
          "data": subRequest.body
        ]
      }
      else {
        self.requestParameters[name] = NSString(data: subRequest.body, encoding: NSUTF8StringEncoding) as? String
      }
    }

  }
  
  //MARK: - Helper Methods
  
  /**
    This method extracts the matching subparts of a line using a regex.

    - parameter line:       The line to extract information from.
    - parameter pattern:    The pattern to match against.
    - returns:              The matched subparts, or an empty array if there
                            was no match.
    */
  public static func extractWithPattern(line : String, pattern : String) -> [String] {
    let regex: NSRegularExpression?
    do {
      regex = try NSRegularExpression(pattern: pattern, options: [])
    } catch _ {
      regex = nil
    }
    var sections : [String] = []
    
    regex?.enumerateMatchesInString(line, options: [], range: NSMakeRange(0,line.characters.count), usingBlock: {
      (result, _, _) in
      sections = []
      guard let result = result else { return }
      for index in 1..<result.numberOfRanges {
        let range = result.rangeAtIndex(index)
        if range.location == NSNotFound { continue }
        let startIndex = advance(line.startIndex, range.location)
        let endIndex = advance(startIndex, range.length)
        let section = line.substringWithRange(Range(start: startIndex, end: endIndex))
        sections.append(section)
      }
    })
    return sections
  }
  
  /**
    This method parses a timestamp from a header value.

    This will accept timestamps in RFC-822 format, RFC-850 format, or Posix
    asctime format.
  
    - param string:   The header value
    - returns:        The timestamp.
    */
  public static func parseTime(string: String) -> Timestamp? {
    return TimeFormat.Rfc822.parseTime(string) ??
      TimeFormat.Rfc850.parseTime(string) ??
      TimeFormat.Posix.parseTime(string)
  }
  
  /**
    This method decodes a query string into a dictionary of parameters.

    - parameter string:     The query string.
    - returns:              The parameters.
    */
  public static func decodeQueryString(string: String) -> [String:String] {
    var params: [String:String] = [:]
    let simplifiedString = string.stringByReplacingOccurrencesOfString("+", withString: "%20")
    for param in simplifiedString.componentsSeparatedByString("&") {
      let components = param.componentsSeparatedByString("=").map {
        $0.stringByRemovingPercentEncoding ?? $0
      }
      if components.count == 1 {
        params[components[0]] = ""
      }
      else {
        params[components[0]] = components[1]
      }
    }
    return params
  }
  
  //MARK: - Test Helpers
  
  /**
    This method crafts a request with desired properties. It is intended for use
    in testing.

    - parameter parameters:       The request parameters.
    - parameter sessionData:      The data for the session.
    - parameter cookies:          The cookie data.
    - parameter method:           The HTTP method
    - parameter clientAddress:    The client's remote IP address.
    - parameter headers:          Additional headers to put in the request.
    - parameter path:             The path that the request should go to.
    */
  public init(clientAddress: String = "0.0.0.0", method: String = "GET", parameters: [String: String] = [:], sessionData: [String: String] = [:], cookies: [String:String] = [:], headers: [String:String] = [:], path: String = "/") {
    var lines = [
      "\(method) \(path) HTTP/1.1"
    ]
    
    lines.append("Content-Type: application/x-www-form-urlencoded")
    
    if !sessionData.isEmpty {
      var session = Session(request: Request(clientAddress: clientAddress, data: NSData()))
      for (key, value) in sessionData {
        session[key] = value
      }
      lines.append("Cookie: _session=\(session.cookieString())")
    }
    for (key,value) in cookies {
      lines.append("Cookie: \(key)=\(value)")
    }
    for (key,value) in headers {
      lines.append("\(key): \(value)")
    }
    
    lines.append("")
    
    var queryString = ""
    
    for (key, value) in parameters {
      if !queryString.isEmpty {
        queryString += "&"
      }
      let convertedValue = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet()
) ?? ""
      queryString += key + "=" + convertedValue
    }
    lines.append(queryString)
    let stringData = lines.reduce("") { buffer, element in buffer.isEmpty ? element : buffer + "\r\n" + element }
    let data = NSData(bytes: stringData.utf8)
    self.init(clientAddress: clientAddress, data: data)
  }
}

/**
  This method determines if two requests are equal.

  Requests are equal when they have the same request data.

  - parameter lhs:    The left-hand side of the operator
  - parameter rhs:    The right-hand side of the operator
  - returns:          Whether the two requests are equal.
  */
public func ==(lhs: Request, rhs: Request) -> Bool {
  return lhs.data == rhs.data
}