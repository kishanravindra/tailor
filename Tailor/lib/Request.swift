import Foundation

/**
  This class represents a request from the client.
  */
struct Request {
  /** The full request data. */
  let data: NSData
  
  /** The HTTP method. */
  let method: String
  
  /** The HTTP version */
  let version: String
  
  /** The path that the client is requesting. */
  let path: NSString
  
  /** The header information from the request. */
  let headers: [String: String]
  
  /** The full request data. */
  let body: NSData
  
  /**
    This method initializes a request.

    :param: data  The full request data.
    */
  init(data: NSData) {
    self.data = data
    let fullBody = NSString(data: data, encoding: NSUTF8StringEncoding) as NSString
    
    let lines = fullBody.componentsSeparatedByString("\n") as [String]
    let introMatches = Request.extractWithPattern(lines[0], pattern: "^([\\S]*) ([\\S]*) HTTP/([\\d.]*)$")
    self.method = introMatches[0]
    self.path = introMatches[1]
    
    NSLog("%@ %@", self.method, self.path)
    self.version = introMatches[2]
    
    var lastHeaderLine = lines.count - 1
    var headers : [String:String] = [:]
    for index in 1..<lines.count {
      let line = lines[index].stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
      if line.isEmpty {
        lastHeaderLine = index
        break
      }
      let headerMatch = Request.extractWithPattern(line, pattern: "^([\\w-]*): (.*)$")
      headers[headerMatch[0]] = headerMatch[1]
    }
    
    let headerLines = lines[0...lastHeaderLine]
    var headerLength = 0
    for index in 0...lastHeaderLine {
      headerLength += countElements(lines[index]) + 1
    }
    
    self.body = data.subdataWithRange(NSMakeRange(headerLength, data.length - headerLength))
    self.headers = headers
  }
  
  //MARK: - Body Parsing
  
  /** The text of the request body. */
  var bodyText : String { get {
    return NSString(data: self.body, encoding: NSUTF8StringEncoding)
  } }
  
  /** The request parameters from the query string and the request body. */
  var requestParameters: [String:String] { get {
    var params: [String:String] = [:]
    let queryStringLocation = self.path.rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch)
    if queryStringLocation.location != NSNotFound {
      let queryString = self.path.substringFromIndex(queryStringLocation.location + 1)
      for (key, value) in Request.decodeQueryString(queryString) {
        params[key] = value
      }
    }
    
    if headers["Content-Type"] != nil && headers["Content-Type"]! == "application/x-www-form-urlencoded" {
      for (key,value) in Request.decodeQueryString(self.bodyText) {
        params[key] = value
      }
    }
    return params
  }}
  
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
    NSLog("Encoded string is %@", string)
    for param in string.componentsSeparatedByString("&") {
      let components = param.componentsSeparatedByString("=").map {
        $0.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
      }
      NSLog("Components are %@", components)
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