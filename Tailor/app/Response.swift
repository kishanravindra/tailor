import Foundation

/**
  This class represents a response to a request.
  */
public struct Response {
  /** The HTTP response code. */
  public var code = 200
  
  /** The response headers. */
  public var headers: [String:String] = [:]
  
  /** The data for the response body. */
  public var bodyData = NSMutableData()
  
  /** The cookies that should be updated with this response. */
  public var cookies = CookieJar()
  
  /**
    This method initializes an empty response.
    */
  public init() {
    
  }
  
  //MARK: - Response Data
  
  /**
    This method appends a string to the response.

    :param: string  The string to add
    */
  public func appendString(string: String) {
    self.appendData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
  }
  
  /**
    This method appends raw data to the response.

    :param: data  The data to add.
    */
  public func appendData(data: NSData) {
    bodyData.appendData(data)
  }
  
  /** The full HTTP response data. */
  public var data : NSData { get {
    let data = NSMutableData()
    
    func add(string: String) {
      if let newData = string.dataUsingEncoding(NSUTF8StringEncoding) {
        data.appendData(newData)
      }
    }
    
    add(NSString(format: "HTTP/1.1 %d\n", code))
    add(NSString(format: "Content-Length: %d\n", bodyData.length))
    
    for (key,value) in self.headers {
      add(NSString(format: "%@: %@ \n", key, value))
    }
    add(cookies.headerStringForChanges)
    add("\n")
    data.appendData(bodyData)
    return data
  } }
}