import Foundation

/**
  This class represents a response to a request.
  */
struct Response {
  /** The HTTP response code. */
  var code = 200
  
  /** The response headers. */
  var headers: [String:String] = [:]
  
  /** The data for the response body. */
  var bodyData = NSMutableData()
  
  /** The cookies that should be updated with this response. */
  var cookies = CookieJar()
  
  //MARK: - Response Data
  
  /**
    This method appends a string to the response.

    :param: string  The string to add
    */
  func appendString(string: String) {
    bodyData.appendData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
  }
  
  /** The full HTTP response data. */
  var data : NSData { get {
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