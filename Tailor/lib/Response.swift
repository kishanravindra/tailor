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
    let introString = NSString(format: "HTTP/1.1 %d\n", code)
    data.appendData(introString.dataUsingEncoding(NSUTF8StringEncoding)!)
    for (key,value) in self.headers {
      let headerString = NSString(format: "%s: %s\n", key, value)
      data.appendData(introString.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    data.appendData("\n".dataUsingEncoding(NSUTF8StringEncoding)!)
    data.appendData(bodyData)
    return data
  } }
}