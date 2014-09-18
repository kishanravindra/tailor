import Foundation

/**
  This class represents a request from the client.
  */
struct Request {
  /** The client's IP address. */
  let clientAddress: String
  
  /** The full request data. */
  let data: NSData
  
  /** The HTTP method. */
  let method: String
  
  /** The HTTP version */
  let version: String
  
  /** The full path from the request. */
  let fullPath: String
  
  /** The path that the client is requesting, without the query string. */
  let path: String
  
  /** The header information from the request. */
  let headers: [String: String]
  
  /** The full request data. */
  let body: NSData
  
  /** The request parameters. */
  var requestParameters: [String:String] = [:]
  
  /** The cookies that were sent with this request. */
  let cookies = CookieJar()
  
  /**
    This method initializes a request.

    :param: clientAddress   The client's IP address.
    :param: data            The full request data.
    */
  init(clientAddress: String, data: NSData) {
    self.clientAddress = clientAddress
    self.data = data
    let fullBody = NSString(data: data, encoding: NSUTF8StringEncoding) as NSString
    
    let lines = fullBody.componentsSeparatedByString("\n") as [String]
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
    }
    
    if let queryStringLocation = self.fullPath.rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch) {
      self.path = self.fullPath.substringToIndex(queryStringLocation.startIndex)
    }
    else {
      self.path = self.fullPath
    }
    
    var lastHeaderLine = lines.count - 1
    var headers : [String:String] = [:]
    for index in 1..<lines.count {
      let line = lines[index].stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
      if line.isEmpty {
        lastHeaderLine = index
        break
      }
      let headerMatch = Request.extractWithPattern(line, pattern: "^([\\w-]*): (.*)$")
      
      if headerMatch[0] == "Cookie" {
        self.cookies.addHeaderString(headerMatch[1])
      }
      else {
        headers[headerMatch[0]] = headerMatch[1]
      }
    }
    
    let headerLines = lines[0...lastHeaderLine]
    var headerLength = 0
    for index in 0...lastHeaderLine {
      headerLength += countElements(lines[index]) + 1
    }
    
    let range = NSMakeRange(headerLength, data.length - headerLength)
    
    if range.length > 0 {
      self.body = data.subdataWithRange(range)
    }
    else {
      self.body = NSData()
    }
    self.headers = headers
    
    self.parseRequestParameters()
  }
  
  //MARK: - Body Parsing
  
  /** The text of the request body. */
  var bodyText : String { get {
    return NSString(data: self.body, encoding: NSUTF8StringEncoding)
  } }
  
  /**
    This method extracts the request parameters from the query string and the
    request body.
    */
  mutating func parseRequestParameters() {
    let queryStringLocation = self.fullPath.rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch)
    if queryStringLocation != nil {
      let queryString = self.fullPath.substringFromIndex(queryStringLocation!.startIndex.successor())
      for (key, value) in Request.decodeQueryString(queryString) {
        self.requestParameters[key] = value
      }
    }
    
    if headers["Content-Type"] != nil && headers["Content-Type"]! == "application/x-www-form-urlencoded" {
      for (key,value) in Request.decodeQueryString(self.bodyText) {
        self.requestParameters[key] = value
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
  static func extractWithPattern(line : String, pattern : String) -> [String] {
    let regex = NSRegularExpression(pattern: pattern, options: nil, error: nil)
    var sections : [String] = []
    regex.enumerateMatchesInString(line, options: nil, range: NSMakeRange(0,countElements(line)), usingBlock: {
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
  static func decodeQueryString(string: String) -> [String:String] {
    var params: [String:String] = [:]
    for param in string.componentsSeparatedByString("&") {
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
}