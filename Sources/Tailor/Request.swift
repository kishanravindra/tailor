import Foundation

/**
  This type represents a request from the client.
  */
public struct Request: HttpMessageType, Equatable {
  /**
    This type represents a dictionary of request parameters.

    It wraps around the raw dictionary and provides automatic type
    conversion and fallbacks.
    */
  public struct ParameterDictionary: Equatable {
    //MARK: - Structure
    
    /** The raw request parameters. */
    public var raw: [String:[String]]
    
    /**
      This initializer creates a parameter dictionary with request
      parameters.

      - parameter flatParameters:     The request parameters, with the values as
                                      strings rather than arrays.
      */
    public init(_ flatParameters: [String:String] = [:]) {
      self.raw = flatParameters.map { [$0] }
    }
    
    /**
     This initializer creates a parameter dictionary with request
     parameters.
     
     - parameter parameters:    The request parameters.
     */
    public init(_ parameters: [String:[String]]) {
      self.raw = parameters
    }
    
    
    //MARK: - Parameter Access
    
    /**
      This method adds a value to the list of parameters for a key.

      If there are no parameters for that key yet, this will make the new value
      the first parameter.
    
      - parameter value:    The value to add to the list.
      - parameter key:      The key to add the value for.
      */
    public mutating func append(value value: String, forKey key: String) {
      var values = self.raw[key] ?? []
      values.append(value)
      self.raw[key] = values
    }
    
    /**
      This method looks up a value as a list of strings.
      */
    public subscript(key: String) -> [String] {
      get {
        return self.raw[key] ?? []
      }
      set {
        self.raw[key] = newValue
      }
    }
    
    /**
      This subscript looks up a value as an optional string.
      */
    public subscript(key: String) -> String? {
      get {
        let values = self.raw[key] ?? []
        return values.first
      }
      set {
        self.raw[key] = [newValue].flatMap { $0 }
      }
    }
    
    /**
      This subscript looks up a value as a non-optional string.

      If the value is missing, this will return an empty string.
      */
    public subscript(key: String) -> String {
      get {
        return self[key] as String? ?? ""
      }
      set {
        self.raw[key] = [newValue]
      }
    }
    
    /**
      This subscript looks up a value as an optional integer.

      If the value is missing, or is not an integer, this will return nil.
      */
    public subscript(key: String) -> Int? {
      get {
        return Int(self[key] as String)
      }
      set {
        if let value = newValue {
          self[key] = String(value)
        }
        else {
          self[key] = []
        }
      }
    }
    
    /**
      This subscript looks up a value as a non-optional integer.
      
      If the value is missing, or is not an integer, this will return zero.
      */
    public subscript(key: String) -> Int {
      get {
        return self[key] as Int? ?? 0
      }
      set {
        self[key] = String(newValue)
      }
    }
  }
  
  /** The client's IP address. */
  public var clientAddress: String = "0.0.0.0"

  /** The status line from the message. */
  public var statusLine: String {
    return "\(method) \(fullPath) HTTP/\(version)"
  }
  
  /** The HTTP method. */
  public let method: String
  
  /** The HTTP version */
  public let version: String
  
  /** The full path from the request. */
  public let fullPath: String
  
  /** The path that the client is requesting, without the query string. */
  public let path: String
  
  /** The header information from the request. */
  public var headers: [String: String]
  
  /** The full request data. */
  @available(*, deprecated, message="Use bodyData instead")
  public var body: NSData {
    get { return bodyData }
    set { self.bodyData = newValue }
  }

  /** The body data. */
  public var bodyData: NSData
  
  /** The request parameters. */
  public var params = ParameterDictionary()

  /** Whether this message type sets cookies */
  public let setsCookies = false

  /** Whether this message has a pre-defined length. */
  public let hasDefinedLength = true

  /** Whether this message only contains a body */
  public let bodyOnly = false

  /** The domain that the request is being made to. */
  public var domain: String

  /** Whether the request should be made using a secure connection. */
  public var secure: Bool = true
  
  /**
    The request parameters.
  
    This has been deprecated in favor of the new `params` dictionary.
    */
  @available(*, deprecated, message="Use params instead")
  public var requestParameters: [String:String] {
    get {
      return params.raw.map { $0.first ?? "" }
    }
    set {
      params.raw = newValue.map { [$0] }
    }
  }
  
  /** The session information. */
  public var session: Session
  
  /**
    The files that were uploaded in this request.

    This will map the parameter name for the file to a hash containing the 
    contentType and the data.
  */
  public var uploadedFiles: [String:[String:Any]] = [:]
  
  /** The cookies that were sent with this request. */
  public var cookies: CookieJar
  
  /**
    This initializer creates a request.

    - parameter clientAddress:   The client's IP address.
    - parameter data:            The full request data.
    */
  public init(clientAddress: String, data: NSData) {
    self.init(data: data)
    self.clientAddress = clientAddress
  }

  /**
    This initializer creates a request from the message components.

    - parameter statusLine:   The HTTP status line.
    - parameter headers:      The headers
    - parameter cookies:      The cookies
    - parameter bodyData:     The body data.
    */
  public init(statusLine: String, headers: [String: String], cookies: CookieJar, bodyData: NSData) {
    self.headers = headers
    self.cookies = cookies
    self.bodyData = bodyData

    let introMatches = Request.extractWithPattern(statusLine, pattern: "^([\\S]*) ([\\S]*) HTTP/([\\d.]*)$")
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
    
    let queryStringLocation = self.fullPath.bridge().rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch)
    if queryStringLocation.location != NSNotFound {
      self.path = self.fullPath.bridge().substringToIndex(queryStringLocation.location)
    }
    else {
      self.path = self.fullPath
    }
    self.domain = headers["Host"] ?? ""

    self.session = Session(cookieString: cookies["_session"] ?? "", clientAddress: clientAddress)
    self.parseRequestParameters()
  }
  
  //MARK: - Body Parsing
  
  /**
    This method extracts the request parameters from the query string and the
    request body.
    */
  private mutating func parseRequestParameters() {
    let queryStringLocation = self.fullPath.bridge().rangeOfString("?", options: NSStringCompareOptions.BackwardsSearch)
    if queryStringLocation.location != NSNotFound {
      let queryString = self.fullPath.bridge().substringFromIndex(queryStringLocation.location + 1)
      for (key, value) in Request.decodeQueryString(queryString) {
        self.params[key] = value
      }
    }
    
    if let contentType = headers["Content-Type"] {
      if contentType.hasPrefix("application/x-www-form-urlencoded") {
        for (key,value) in Request.decodeQueryString(self.bodyText) {
          self.params[key] = value
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
    
    let boundaryComponents = contentType.bridge().componentsSeparatedByString("boundary=")
    guard boundaryComponents.count > 1 else { return }
    
    let boundary = boundaryComponents[1]
    let components = self.bodyData.componentsSeparatedByString("--\(boundary)")
    for component in components {
      if component.length <= 4 {
        continue
      }
      let trimmedData = component.subdataWithRange(NSRange(location: 0, length: component.length - 2))
      let subRequest = Request(clientAddress: self.clientAddress, data: trimmedData)
      
      var parameterName : String? = nil
      
      if let disposition = subRequest.headers["Content-Disposition"] {
        for dispositionComponent in disposition.bridge().componentsSeparatedByString("; ") {
          if dispositionComponent.hasPrefix("name=") {
            parameterName = dispositionComponent.bridge().substringFromIndex(5).bridge().stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
          }
        }
      }
      
      guard let name = parameterName else { continue }
      
      if let contentType = subRequest.headers["Content-Type"] {
        self.uploadedFiles[name] = [
          "contentType": contentType,
          "data": subRequest.bodyData
        ]
      }
      else {
        self.params[name] = NSString(data: subRequest.bodyData, encoding: NSUTF8StringEncoding)?.bridge()
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
        let section = line.bridge().substringWithRange(range)
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
    return TimeFormat.Rfc822.parseTimestamp(string) ??
      TimeFormat.Rfc850.parseTimestamp(string) ??
      TimeFormat.Posix.parseTimestamp(string)
  }
  
  /**
    This method decodes a query string into a dictionary of parameters.

    - parameter string:     The query string.
    - returns:              The parameters.
    */
  public static func decodeQueryString(string: String) -> [String:[String]] {
    if string == "" { return [:] }
    var params: [String:[String]] = [:]
    let simplifiedString = string.bridge().stringByReplacingOccurrencesOfString("+", withString: "%20")
    for param in simplifiedString.bridge().componentsSeparatedByString("&") {
      let components = param.bridge().componentsSeparatedByString("=").map {
        $0.bridge().stringByRemovingPercentEncoding ?? $0
      }
      let key = components[0]
      let value: String
      if components.count == 1 {
        value = ""
      }
      else {
        value = components[1]
      }
      var values = params[key] ?? []
      values.append(value)
      params[key] = values
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
    - parameter domain:           The domain that we are making the request to.
    - parameter path:             The path that the request should go to.
    - parameter secure:           Whether we should use a secure (HTTPS)
                                  connection to make the request.
    */
  public init(clientAddress: String = "0.0.0.0", method: String = "GET", parameters: [String: String] = [:], sessionData: [String: String] = [:], cookies: [String:String] = [:], headers: [String:String] = [:], domain: String = "", path: String = "/", secure: Bool = true) {
    var path = path
    let bodyData: NSData
    
    var queryString = ""
    
    for (key, value) in parameters {
      if !queryString.isEmpty {
        queryString += "&"
      }
      let convertedKey = key.bridge().stringByAddingPercentEncodingWithAllowedCharacters(.URLParameterAllowedCharacterSet()) ?? ""
      let convertedValue = value.bridge().stringByAddingPercentEncodingWithAllowedCharacters(.URLParameterAllowedCharacterSet()
        ) ?? ""
      queryString += convertedKey + "=" + convertedValue
    }
    
    if method == "GET" {
      if !queryString.isEmpty {
        path += "?" + queryString
      }
      bodyData = NSData()
    }
    else {
      bodyData = NSData(bytes: queryString.utf8)
    }
    
    var headers = headers
    headers["User-Agent"] = "Tailor Application"
    headers["Content-Type"] = "application/x-www-form-urlencoded"
    headers["Host"] = domain

    var cookieJar = CookieJar()
    
    if !sessionData.isEmpty {
      var session = Session(cookieString: "", clientAddress: clientAddress)
      for (key, value) in sessionData {
        session[key] = value
      }
      cookieJar["_session"] = session.cookieString()
    }
    for (key,value) in cookies {
      cookieJar[key] = value
    }

    self.init(statusLine: "\(method) \(path) HTTP/1.1", headers: headers, cookies: cookieJar, bodyData: bodyData)
    self.clientAddress = clientAddress
    self.secure = secure
  }

  //MARK: - Sending Requests

  /**
    This method sends the request to the server asynchronously.

    - parameter callback:   The callback to invoke when the response is ready.
    */
  public func send(callback: Connection.ResponseCallback) {
    Connection.sendRequest(self, callback: callback)
  }

  /**
    This method sends the request to the server synchronously.
    - returns:    The response from the server.
    */
  public func send() -> Response {
    return Connection.sendRequest(self)
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

public extension Request {
  /**
    This type provides a set of preferences for what kind of content a server
    should provide in response to a request.

    A request will have multiple preferences for different aspect of the
    content: the format, the encoding, the charset, or the language. Each
    preference specifies one or more acceptable options, in order of preference.
    */
  public struct ContentPreference: Equatable {
    /**
      This type provides an option for an acceptable format for a response.
      */
    public struct Option: Equatable {
      /**
        The main type of the format.
        */
      public let type: String
      
      /**
        The subtype of the format.
        */
      public let subtype: String
      
      /**
        The flags that qualify the type.
        */
      public let flags: [String:String]
      
      /**
        The quality that determines how favored this option is.

        The quality must be between 0 and 1. Highever values are more favored.
        */
      public let quality: Double
      
      /**
        This initializer creates a content preference option.

        - parameter type:       The main type for the option.
        - parameter subtype:    The subtype for the option.
        - parameter flags:      The flags that qualify the type.
        - parameter quality:    The quality that specifies how favored this
                                option is.
        */
      public init(type: String, subtype: String = "", flags: [String:String] = [:], quality: Double = 1) {
        self.type = type
        self.subtype = subtype
        self.flags = flags
        self.quality = quality
      }
      
      /**
        This initializer creates a content preference option from a formatted
        header string.

        The general format for the header string is "type/subtype;q=0.5;foo=bar".
        Type and subtype in that string represent the type and subtype on the
        option. "foo=bar" and other similar sections indicate flags to set on
        the option. The q flag is treated specially, because it provides the
        quality field.

        - parameter header:   The header string.
        */
      public init(fromHeader header: String) {
        let components = header.characters.split(";")
        let fullType = String(components[0])
        var quality: Double = 1
        var flags = [String:String]()
        let type: String
        let subtype: String
        
        if fullType.contains("/") {
          let splitType = fullType.characters.split("/")
          type = String(splitType[0])
          subtype = String(splitType[1])
        }
        else {
          type = fullType
          subtype = ""
        }
        for indexOfComponent in 1..<components.count {
          let splitFlag = components[indexOfComponent].split("=")
          if splitFlag.count == 2 {
            let key = String(splitFlag[0]).bridge().stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
            let value = String(splitFlag[1]).bridge().stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
            if key == "q" {
              quality = Double(value) ?? 0
            }
            else {
              flags[key] = value
            }
          }
        }
        self.init(
          type: type.bridge().stringByTrimmingCharactersInSet(.whitespaceCharacterSet()),
          subtype: subtype.bridge().stringByTrimmingCharactersInSet(.whitespaceCharacterSet()),
          flags: flags,
          quality: quality)
      }
      
      /**
        This method determines if this option is a match for a proposed value.

        The value should be formatted in the same way as a header string in the
        initializer. 

        In order to match, the proposed value must have the same type and value
        as this option, and must have a matching value for every flag in this
        option. If the type or subtype is an asterisk, it will be interpreted as
        a wildcard that accepts any value in that field.
      
        - parameter string:   The value to check.
        - returns:            Whether this option accepts the value.
        */
      public func matches(string: String) -> Bool {
        let parsedOption = Option(fromHeader: string)
        if self.type != parsedOption.type && self.type != "*" { return false }
        if self.subtype != parsedOption.subtype && self.subtype != "*" { return false }
        for (key,value) in self.flags {
          if parsedOption.flags[key] != value {
            return false
          }
        }
        return true
      }
    }
    
    /**
      The options that this content preference accepts, in order from most
      favored to least favored.
      */
    public let options: [Option]
    
    /**
      This initializer creates a preferences from a list of content options.
    
      - parameter options:    The options that this content preference accepts,
                              in order from most favored to least favored.
      */
    public init(options: [Option]) {
      self.options = options
    }
    
    /**
      This initializer creates a content preference from a header string.

      The header string must contain a set of content options, separated by
      commas. For instance: "application/html;q=1,application/xml;q=0.5".
      
      - parameter header:   The header string
      */
    public init(fromHeader header: String) {
      let options: [Option] = header.characters.split(",").map {
        Option(fromHeader: String($0))
        }.sort { $0.quality > $1.quality }
      self.init(options: options)
    }
    
    /**
      This method identifies the option that is the best match out of a list
      of options.

      This will pick the entry from the allowed values that matches the highest
      entry in our list of options.

      - parameter allowedValues:    The values that we are selecting from.
      - returns:                    The best option from the allowed values.
      */
    public func bestMatch(allowedValues: String...) -> String? {
      return self.bestMatch(allowedValues)
    }
    
    /**
      This method identifies the option that is the best match out of a list
      of options.
      
      This will pick the entry from the allowed values that matches the highest
      entry in our list of options.
      
      - parameter allowedValues:    The values that we are selecting from.
      - returns:                    The best option from the allowed values.
      */
    public func bestMatch(allowedValues: [String]) -> String? {
      return allowedValues.filter {
        value in
        !self.options.filter { $0.matches(value) }.isEmpty
        }.sort {
        lhs,rhs in
        let index1 = self.options.indexOf { $0.matches(lhs) } ?? self.options.endIndex
        let index2 = self.options.indexOf { $0.matches(rhs) } ?? self.options.endIndex
        return index1 < index2
      }.first
    }
  }
}

/**
  This method determines if two content preferences are equal.

  They are equal if they have the same content options.

  - parameter lhs:    The left-hand side of the comparison
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two are equal.
  */
public func ==(lhs: Request.ContentPreference, rhs: Request.ContentPreference) -> Bool {
  return lhs.options == rhs.options
}

/**
  This method determines if two content options are equal.

  They are equal if they have the same type, subtype, flags, and options.

  - parameter lhs:    The left-hand side of the comparison
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two are equal.
  */
public func ==(lhs: Request.ContentPreference.Option, rhs: Request.ContentPreference.Option) -> Bool {
  return lhs.type == rhs.type &&
    lhs.subtype == rhs.subtype &&
    lhs.flags == rhs.flags &&
    lhs.quality == rhs.quality
}

/**
  This method determines if two parameter dictionaries are equal.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two dictionaries are equal.
  */
public func ==(lhs: Request.ParameterDictionary, rhs: Request.ParameterDictionary) -> Bool {
  return lhs == rhs.raw
}


/**
 This method determines if two parameter dictionaries are equal.
 
 - parameter lhs:    The left-hand side of the comparison.
 - parameter rhs:    The right-hand side of the comparison.
 - returns:          Whether the two dictionaries are equal.
 */
public func ==(lhs: Request.ParameterDictionary, rhs: [String:[String]]) -> Bool {
  let leftKeysMatch = lhs.raw.keys.filter {
    if let leftValue = lhs.raw[$0], rightValue = rhs[$0] {
      return leftValue != rightValue
    }
    else {
      return true
    }
    }.isEmpty
  let rightKeysMatch = rhs.keys.filter { lhs.raw[$0] == nil }.isEmpty
  return leftKeysMatch && rightKeysMatch
}