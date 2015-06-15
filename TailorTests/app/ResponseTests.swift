import XCTest
import Tailor
import TailorTesting

class ResponseTests: TailorTestCase {
  var response = Response()
  
  var responseLines: [String] { get {
    let responseString = NSString(data: response.data, encoding: NSUTF8StringEncoding)
    return responseString!.componentsSeparatedByString("\n") as [String]
  }}
  
  func setUpFullResponse() {
    response.cookies.addHeaderString("key1=value1; key2=value2")
    response.cookies["key2"] = "value4"
    response.cookies["key3"] = "value3"
    response.headers["X-Custom-Header"] = "header value"
    response.code = 302
    response.appendString("You are being redirected")
  }
  
  
  //MARK: - Response Data
  
  func testAppendStringAppendsToBody() {
    response.appendString("Test")
    response.appendString("String")
    let data = "TestString".dataUsingEncoding(NSUTF8StringEncoding)!
    assert(response.bodyData, equals: data, message: "sets the body data to the combined strings")
  }
  
  func testAppendDataAppendsToBody() {
    let bytes = [1,2,3,4]
    let data = NSData(bytes: bytes, length: bytes.count)
    response.appendData(data)
    assert(response.bodyData, equals: data, message: "sets the body data to the data given")
  }
  
  func testResponseDataContainsHTTPCode() {
    setUpFullResponse()
    assert(responseLines[0], equals: "HTTP/1.1 302", message: "response has HTTP intro line")
  }
  
  func testResponseDataContainsHeaders() {
    setUpFullResponse()
    assert(responseLines[1], equals: "Content-Length: 24", message: "has the body length as the content length header")
    assert(responseLines[2], equals: "X-Custom-Header: header value", message: "has a custom header in the headers")
  }
  
  func testResponseDataContainsCookieHeaders() {
    setUpFullResponse()
    assert(responseLines[3], equals: "Set-Cookie: key2=value4; Path=/", message: "has a cookie header for a changed cookie")
    assert(responseLines[4], equals: "Set-Cookie: key3=value3; Path=/", message: "has a cookie header for a new cookie")
  }
  
  func testResponseDataContainsBody() {
    setUpFullResponse()
    assert(responseLines[6], equals: "You are being redirected")
  }
  
  func testResponseBodyStringContainsBody() {
    setUpFullResponse()
    response.appendString(". Test")
    response.appendString("Body")
    let string = response.bodyString
    assert(string, equals: "You are being redirected. TestBody", message: "has the full body")
  }
}
