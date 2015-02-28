import Foundation

/**
  This class represents a request from the client.
  */
public struct Request {
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
  public let cookies = CookieJar()
  
  /**
    This method initializes a request.

    :param: clientAddress   The client's IP address.
    :param: data            The full request data.
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
    
    var lines = headerString.componentsSeparatedByString("\r\n") as! [String]
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
    for index in 1..<lines.count {
      let line = lines[index].stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
      if line.isEmpty {
        continue
      }
      let headerMatch = Request.extractWithPattern(line, pattern: "^([\\w-]*): (.*)$")
      
      if !headerMatch.isEmpty {
        if headerMatch[0] == "Cookie" {
          cookieHeaders.append(headerMatch[1])
        }
        else {
          headers[headerMatch[0]] = headerMatch[1]
        }
      }
    }
    
    self.headers = headers
    
    for header in cookieHeaders {
      self.cookies.addHeaderString(header)
    }
    
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
    let queryStringLocation = self.fullPath.rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch)
    if queryStringLocation != nil {
      let queryString = self.fullPath.substringFromIndex(queryStringLocation!.startIndex.successor())
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
    let boundary = headers["Content-Type"]!.componentsSeparatedByString("boundary=")[1]
    let components = self.body.componentsSeparatedByString("--\(boundary)")
    for component in components {
      if component.length <= 4 {
        continue
      }
      let trimmedData = component.subdataWithRange(NSRange(location: 2, length: component.length - 4))
      let subRequest = Request(clientAddress: self.clientAddress, data: trimmedData)
      
      var parameterName : String! = nil
      
      if let disposition = subRequest.headers["Content-Disposition"] {
        for dispositionComponent in disposition.componentsSeparatedByString("; ") {
          if dispositionComponent.hasPrefix("name=") {
            parameterName = dispositionComponent.substringFromIndex(advance(dispositionComponent.startIndex, 5)).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
          }
        }
      }
      
      if parameterName == nil {
        continue
      }
      
      if let contentType = subRequest.headers["Content-Type"] {
        self.uploadedFiles[parameterName] = [
          "contentType": contentType,
          "data": subRequest.body
        ]
      }
      else {
        self.requestParameters[parameterName] = NSString(data: subRequest.body, encoding: NSUTF8StringEncoding) as? String
      }
    }

  }
  
  //MARK: - Helper Methods
  
  /**
    This method extracts the matching subparts of a line using a regex.

    :param: line      The line to extract information from.
    :param: pattern   The pattern to match against.
    :returns:         The matched subparts, or an empty array if there was no
                      match.
    */
  public static func extractWithPattern(line : String, pattern : String) -> [String] {
    let regex = NSRegularExpression(pattern: pattern, options: nil, error: nil)
    var sections : [String] = []
    
    regex?.enumerateMatchesInString(line, options: nil, range: NSMakeRange(0,count(line)), usingBlock: {
      (result: NSTextCheckingResult!, _, _) in
      sections = []
      for index in 1..<result.numberOfRanges {
        let range = result.rangeAtIndex(index)
        let startIndex = advance(line.startIndex, range.location)
        let endIndex = advance(startIndex, range.length)
        let section = line.substringWithRange(Range(start: startIndex, end: endIndex))
        sections.append(section)
      }
    })
    return sections
  }
  
  /**
    This method decodes a query string into a dictionary of parameters.

    :param: string          The query string.
    :returns:               The parameters.
    */
  public static func decodeQueryString(string: String) -> [String:String] {
    var params: [String:String] = [:]
    var simplifiedString = string.stringByReplacingOccurrencesOfString("+", withString: "%20")
    for param in simplifiedString.componentsSeparatedByString("&") {
      let components = param.componentsSeparatedByString("=").map {
        $0.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
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

    :param: parameters      The request parameters.
    :param: sessionData     The data for the session.
    :param: cookies         The cookie data.
    :param: method          The HTTP method
    :param: clientAddress   The client's remote IP address.
    */
  public init(clientAddress: String = "0.0.0.0", method: String = "GET", parameters: [String: String] = [:], sessionData: [String: String] = [:], cookies: [String:String] = [:]) {
    var lines = [
      "\(method) / HTTP/1.1"
    ]
    
    lines.append("Content-Type: application/x-www-form-urlencoded")
    
    if !sessionData.isEmpty {
      let session = Session(request: Request(clientAddress: clientAddress, data: NSData()))
      for (key, value) in sessionData {
        session[key] = value
      }
      lines.append("Cookie: _session=\(session.cookieString())")
    }
    for (key,value) in cookies {
      lines.append("Cookie: \(key)=\(value)")
    }
    
    lines.append("")
    
    var queryString = ""
    
    for (key, value) in parameters {
      if !queryString.isEmpty {
        queryString += "&"
      }
      let convertedValue = value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
      queryString += key + "=" + value
    }
    lines.append(queryString)
    var stringData = join("\r\n", lines)
    var data = stringData.dataUsingEncoding(NSUTF8StringEncoding)!
    self.init(clientAddress: clientAddress, data: data)
  }
}