import Foundation

/**
  This class represents a response to a request.
  */
public struct Response: Equatable {
  /** The HTTP response code. */
  public var code = 200
  
  /** The response headers. */
  public var headers: [String:String] = [:]
  
  /** The data for the response body. */
  private var bodyData = NSMutableData()
  
  /** The cookies that should be updated with this response. */
  public var cookies = CookieJar()
  
  /** The templates that were rendered to produce this response. */
  public var renderedTemplates: [TemplateType] = []
  
  /**
    This method initializes an empty response.
    */
  public init() {
    
  }
  
  //MARK: - Response Data
  
  /**
    This method appends a string to the response.

    - parameter string:  The string to add
    */
  public mutating func appendString(string: String) {
    if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
      self.appendData(data)
    }
  }
  
  /**
    This method appends raw data to the response.

    - parameter data:  The data to add.
    */
  public mutating func appendData(data: NSData) {
    bodyData.appendData(data)
  }
  
  /** A copy of the body data. */
  public var body: NSData { return NSData(data: self.bodyData) }
  
  /** The full HTTP response data. */
  public var data : NSData { get {
    let data = NSMutableData()
    
    func add(string: String) {
      if let newData = string.dataUsingEncoding(NSUTF8StringEncoding) {
        data.appendData(newData)
      }
    }
    
    add(NSString(format: "HTTP/1.1 %d\n", code) as String)
    add(NSString(format: "Content-Length: %d\n", bodyData.length) as String)
    
    for (key,value) in self.headers {
      add(NSString(format: "%@: %@\n", key, value) as String)
    }
    add(cookies.headerStringForChanges)
    add("\n")
    data.appendData(bodyData)
    return data
  } }
  
  /** The string version of the response body. */
  public var bodyString: String { get {
    return NSString(data: self.bodyData, encoding: NSUTF8StringEncoding) as? String ?? ""
  } }
}


/**
  This method determines if two responses are equal.

  Responses are equal if they have the same code, headers, body data, and
  cookies.

  - parameter lhs:    The left-hand side of the operator
  - parameter rhs:    The right-hand side of the operator
  - returns:          Whether the two responses are equal.
  */
public func ==(lhs: Response, rhs: Response) -> Bool {
  return lhs.code == rhs.code &&
    lhs.headers == rhs.headers &&
    lhs.bodyData == rhs.bodyData &&
    lhs.cookies == rhs.cookies
}