import XCTest
import Tailor

class ResponseTests: XCTestCase {
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
    XCTAssertEqual(response.bodyData, data, "sets the body data to the combined strings")
  }
  
  func testAppendDataAppendsToBody() {
    let bytes = [1,2,3,4]
    let data = NSData(bytes: bytes, length: bytes.count)
    response.appendData(data)
    XCTAssertEqual(response.bodyData, data, "sets the body data to the data given")
  }
  
  func testResponseDataContainsHTTPCode() {
    setUpFullResponse()
    XCTAssertEqual(responseLines[0], "HTTP/1.1 302", "response has HTTP intro line")
  }
  
  func testResponseDataContainsHeaders() {
    setUpFullResponse()
    XCTAssertEqual(responseLines[1], "Content-Length: 24", "has the body length as the content length header")
    XCTAssertEqual(responseLines[2], "X-Custom-Header: header value", "has a custom header in the headers")
  }
  
  func testResponseDataContainsCookieHeaders() {
    setUpFullResponse()
    XCTAssertEqual(responseLines[3], "Set-Cookie: key2=value4; Path=/", "has a cookie header for a changed cookie")
    XCTAssertEqual(responseLines[4], "Set-Cookie: key3=value3; Path=/", "has a cookie header for a new cookie")
  }
  
  func testResponseDataContainsBody() {
    setUpFullResponse()
    XCTAssertEqual(responseLines[6], "You are being redirected")
  }
  
  func testResponseBodyStringContainsBody() {
    setUpFullResponse()
    response.appendString(". Test")
    response.appendString("Body")
    let string = response.bodyString
    XCTAssertNotNil(string)
    if string != nil {
      XCTAssertEqual(string!, "You are being redirected. TestBody", "has the full body")
    }
  }
}
