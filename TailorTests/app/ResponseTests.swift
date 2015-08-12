import XCTest
import Tailor
import TailorTesting

class ResponseTests: TailorTestCase {
  var response = Response()
  
  var responseLines: [String] { get {
    let responseString = NSString(data: response.data, encoding: NSUTF8StringEncoding)
    return responseString!.componentsSeparatedByString("\r\n") as [String]
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
    assert(response.body, equals: data, message: "sets the body data to the combined strings")
  }
  
  func testAppendDataAppendsToBody() {
    let bytes = [1,2,3,4]
    let data = NSData(bytes: bytes, length: bytes.count)
    response.appendData(data)
    assert(response.body, equals: data, message: "sets the body data to the data given")
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
  
  func testResponseBodyStringWithNonUTF8DataIsEmptyString() {
    setUpFullResponse()
    response.appendData(NSData(bytes: [0xD8, 0x00]))
    let string = response.bodyString
    assert(string, equals: "")
  }
  
  func testCopyDoesNotShareChanges() {
    let response2 = response
    response.appendString("Hello")
    assert(response2.bodyString, equals: "")
  }
  
  //MARK: - Comparisons
  
  func testResponsesAreEqualWithSameInformation() {
    var response1 = Response()
    var response2 = Response()
    response1.code = 200
    response2.code = 200
    response1.headers = ["Content-Type": "text/plain"]
    response2.headers = ["Content-Type": "text/plain"]
    response1.appendData(NSData(bytes: [1,2,3,4]))
    response2.appendData(NSData(bytes: [1,2,3,4]))
    response1.cookies.setCookie("test", "hello")
    response2.cookies.setCookie("test", "hello")
    assert(response1, equals: response2)
  }
  
  func testResponsesAreUnequalWithDifferentCodes() {
    var response1 = Response()
    var response2 = Response()
    response1.code = 200
    response2.code = 302
    response1.headers = ["Content-Type": "text/plain"]
    response2.headers = ["Content-Type": "text/plain"]
    response1.appendData(NSData(bytes: [1,2,3,4]))
    response2.appendData(NSData(bytes: [1,2,3,4]))
    response1.cookies.setCookie("test", "hello")
    response2.cookies.setCookie("test", "hello")
    assert(response1, doesNotEqual: response2)
  }
  
  
  func testResponsesAreUnequalWithDifferentHeaders() {
    var response1 = Response()
    var response2 = Response()
    response1.code = 200
    response2.code = 200
    response1.headers = ["Content-Type": "text/plain"]
    response2.headers = ["Content-Type": "text/xml"]
    response1.appendData(NSData(bytes: [1,2,3,4]))
    response2.appendData(NSData(bytes: [1,2,3,4]))
    response1.cookies.setCookie("test", "hello")
    response2.cookies.setCookie("test", "hello")
    assert(response1, doesNotEqual: response2)
  }
  
  func testResponsesAreUnequalDifferentBodyData() {
    var response1 = Response()
    var response2 = Response()
    response1.code = 200
    response2.code = 200
    response1.headers = ["Content-Type": "text/plain"]
    response2.headers = ["Content-Type": "text/plain"]
    response1.appendData(NSData(bytes: [1,2,3,4]))
    response2.appendData(NSData(bytes: [1,2,3,5]))
    response1.cookies.setCookie("test", "hello")
    response2.cookies.setCookie("test", "hello")
    assert(response1, doesNotEqual: response2)
  }
  
  func testResponsesAreUnequalWithDifferentCookies() {
    var response1 = Response()
    var response2 = Response()
    response1.code = 200
    response2.code = 200
    response1.headers = ["Content-Type": "text/plain"]
    response2.headers = ["Content-Type": "text/plain"]
    response1.appendData(NSData(bytes: [1,2,3,4]))
    response2.appendData(NSData(bytes: [1,2,3,4]))
    response1.cookies.setCookie("test", "goodbye")
    response2.cookies.setCookie("test", "hello")
    assert(response1, doesNotEqual: response2)
  }
}
