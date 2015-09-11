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
    response.responseCode = .Ok
    response.appendString("You are being redirected")
  }
  
  //MARK: - Response Codes
  
  func testResponseCodeForGenericResponsesUsesCodeParameter() {
    let code1 = Response.Code(110, "Some Information")
    assert(code1.code, equals: 110)
    let code2 = Response.Code(225, "Some Success")
    assert(code2.code, equals: 225)
  }
  
  func testResponseCodeForSpecificResponsesUsesCode() {
    assert(Response.Code.Continue.code, equals: 100)
    assert(Response.Code.SwitchingProtocols.code, equals: 101)
    assert(Response.Code.Ok.code, equals: 200)
    assert(Response.Code.Created.code, equals: 201)
    assert(Response.Code.Accepted.code, equals: 202)
    assert(Response.Code.NonAuthoritativeInformation.code, equals: 203)
    assert(Response.Code.NoContent.code, equals: 204)
    assert(Response.Code.ResetContent.code, equals: 205)
    assert(Response.Code.PartialContent.code, equals: 206)
    assert(Response.Code.MultipleChoices.code, equals: 300)
    assert(Response.Code.MovedPermanently.code, equals: 301)
    assert(Response.Code.Found.code, equals: 302)
    assert(Response.Code.SeeOther.code, equals: 303)
    assert(Response.Code.NotModified.code, equals: 304)
    assert(Response.Code.UseProxy.code, equals: 305)
    assert(Response.Code.TemporaryRedirect.code, equals: 307)
    assert(Response.Code.BadRequest.code, equals: 400)
    assert(Response.Code.Unauthorized.code, equals: 401)
    assert(Response.Code.Forbidden.code, equals: 403)
    assert(Response.Code.NotFound.code, equals: 404)
    assert(Response.Code.MethodNotAllowed.code, equals: 405)
    assert(Response.Code.NotAcceptable.code, equals: 406)
    assert(Response.Code.ProxyAuthenticationRequired.code, equals: 407)
    assert(Response.Code.RequestTimeout.code, equals: 408)
    assert(Response.Code.Conflict.code, equals: 409)
    assert(Response.Code.Gone.code, equals: 410)
    assert(Response.Code.LengthRequired.code, equals: 411)
    assert(Response.Code.PreconditionFailed.code, equals: 412)
    assert(Response.Code.RequestEntityTooLarge.code, equals: 413)
    assert(Response.Code.RequestUriTooLong.code, equals: 414)
    assert(Response.Code.UnsupportedMediaType.code, equals: 415)
    assert(Response.Code.InternalServerError.code, equals: 500)
    assert(Response.Code.NotImplemented.code, equals: 501)
    assert(Response.Code.BadGateway.code, equals: 502)
    assert(Response.Code.ServiceUnavailable.code, equals: 503)
    assert(Response.Code.GatewayTimeout.code, equals: 504)
    assert(Response.Code.HttpVersionNotSupported.code, equals: 505)
  }
  
  func testResponseCodeNameForGenericResponsesUsesNameParameter() {
    let code1 = Response.Code(110, "Some Information")
    assert(code1.description, equals: "Some Information")
    let code2 = Response.Code(225, "Some Success")
    assert(code2.description, equals: "Some Success")
  }
  
  func testResponseCodeNameForSpecificResponsesUsesDescription() {
    assert(Response.Code.Continue.description, equals: "Continue")
    assert(Response.Code.SwitchingProtocols.description, equals: "Switching Protocols")
    assert(Response.Code.Ok.description, equals: "OK")
    assert(Response.Code.Created.description, equals: "Created")
    assert(Response.Code.Accepted.description, equals: "Accepted")
    assert(Response.Code.NonAuthoritativeInformation.description, equals: "Non-Authoritative Information")
    assert(Response.Code.NoContent.description, equals: "No Content")
    assert(Response.Code.ResetContent.description, equals: "Reset Content")
    assert(Response.Code.PartialContent.description, equals: "Partial Content")
    assert(Response.Code.MultipleChoices.description, equals: "Multiple Choices")
    assert(Response.Code.MovedPermanently.description, equals: "Moved Permanently")
    assert(Response.Code.Found.description, equals: "Found")
    assert(Response.Code.SeeOther.description, equals: "See Other")
    assert(Response.Code.NotModified.description, equals: "Not Modified")
    assert(Response.Code.UseProxy.description, equals: "Use Proxy")
    assert(Response.Code.TemporaryRedirect.description, equals: "Temporary Redirect")
    assert(Response.Code.BadRequest.description, equals: "Bad Request")
    assert(Response.Code.Unauthorized.description, equals: "Unauthorized")
    assert(Response.Code.Forbidden.description, equals: "Forbidden")
    assert(Response.Code.NotFound.description, equals: "Not Found")
    assert(Response.Code.MethodNotAllowed.description, equals: "Method Not Allowed")
    assert(Response.Code.NotAcceptable.description, equals: "Not Acceptable")
    assert(Response.Code.ProxyAuthenticationRequired.description, equals: "Proxy Authentication Required")
    assert(Response.Code.RequestTimeout.description, equals: "Request Timeout")
    assert(Response.Code.Conflict.description, equals: "Conflict")
    assert(Response.Code.Gone.description, equals: "Gone")
    assert(Response.Code.LengthRequired.description, equals: "Length Required")
    assert(Response.Code.PreconditionFailed.description, equals: "Precondition Failed")
    assert(Response.Code.RequestEntityTooLarge.description, equals: "Request Entity Too Large")
    assert(Response.Code.RequestUriTooLong.description, equals: "Request-URI Too Long")
    assert(Response.Code.UnsupportedMediaType.description, equals: "Unsupported Media Type")
    assert(Response.Code.RequestedRangeNotSatisfiable.description, equals: "Requested Range Not Satisfiable")
    assert(Response.Code.ExpectationFailed.description, equals: "Expectation Failed")
    assert(Response.Code.InternalServerError.description, equals: "Internal Server Error")
    assert(Response.Code.NotImplemented.description, equals: "Not Implemented")
    assert(Response.Code.BadGateway.description, equals: "Bad Gateway")
    assert(Response.Code.ServiceUnavailable.description, equals: "Service Unavailable")
    assert(Response.Code.GatewayTimeout.description, equals: "Gateway Timeout")
    assert(Response.Code.HttpVersionNotSupported.description, equals: "HTTP Version Not Supported")
  }
  
  //MARK: - Response Data
  
  func testAppendStringAppendsToBody() {
    response.appendString("Test")
    response.appendString("String")
    let data = NSData(bytes: "TestString".utf8)
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
    assert(responseLines[0], equals: "HTTP/1.1 200 OK", message: "response has HTTP intro line")
  }
  
  func testResponseDataContainsCustomHeaders() {
    setUpFullResponse()
    assert(responseLines.contains("X-Custom-Header: header value"), message: "has a custom header in the headers")
  }
  
  func testResponseDataContainsDefaultHeaders() {
    setUpFullResponse()
    
    assert(responseLines.contains("Content-Length: 24"), message: "has the body length as the content length header")
    assert(responseLines.contains("Content-Type: text/html; charset=UTF-8"))
    let date = Timestamp.now().inTimeZone("GMT").format(TimeFormat.Rfc822)
    assert(responseLines.contains("Date: \(date)"), message: "has the current time as the date header")
  }
  
  func testResponseDataAllowsSpecialHeadersToOverrideDefaults() {
    setUpFullResponse()
    response.headers["Content-Length"] = "A"
    response.headers["Content-Type"] = "B"
    response.headers["Date"] = "C"
    
    assert(responseLines.contains("Content-Length: A"))
    assert(responseLines.contains("Content-Type: B"))
    assert(responseLines.contains("Date: C"))
    assert(!responseLines.contains("Content-Length: 24"), message: "does not have the default content length")
    assert(!responseLines.contains("Content-Type: text/html; charset=UTF-8"), message: "does not have the default content type")
    let date = Timestamp.now().inTimeZone("GMT").format(TimeFormat.Rfc822)
    assert(!responseLines.contains("Date: \(date)"), message: "does not have the current time as the date header")
  }
  
  func testResponseDataContainsCookieHeaders() {
    setUpFullResponse()
    assert(responseLines.contains("Set-Cookie: key2=value4; Path=/"), message: "has a cookie header for a changed cookie")
    assert(responseLines.contains("Set-Cookie: key3=value3; Path=/"), message: "has a cookie header for a new cookie")
  }
  
  func testResponseDataContainsBody() {
    setUpFullResponse()
    assert(responseLines.contains("You are being redirected"))
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
  
  func testClearBodyClearsBody() {
    setUpFullResponse()
    response.appendString("Body")
    response.clearBody()
    assert(response.body.length, equals: 0)
  }
  
  //MARK: - Comparisons
  
  func testResponsesAreEqualWithSameInformation() {
    var response1 = Response()
    var response2 = Response()
    response1.responseCode = .Created
    response2.responseCode = .Created
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
    response1.responseCode = .Created
    response2.responseCode = .Accepted
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
    response1.responseCode = .Ok
    response2.responseCode = .Ok
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
    response1.responseCode = .Ok
    response2.responseCode = .Ok
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
    response1.responseCode = .Ok
    response2.responseCode = .Ok
    response1.headers = ["Content-Type": "text/plain"]
    response2.headers = ["Content-Type": "text/plain"]
    response1.appendData(NSData(bytes: [1,2,3,4]))
    response2.appendData(NSData(bytes: [1,2,3,4]))
    response1.cookies.setCookie("test", "goodbye")
    response2.cookies.setCookie("test", "hello")
    assert(response1, doesNotEqual: response2)
  }
  
  func testResponsesAreEqualWithSameCodeAndName() {
    let code1 = Response.Code(200, "OK")
    let code2 = Response.Code(200, "OK")
    assert(code1, equals: code2)
  }
  
  func testResponsesAreNotEqualWithDifferent() {
    let code1 = Response.Code(200, "OK")
    let code2 = Response.Code(201, "OK")
    assert(code1, doesNotEqual: code2)
  }
  
  func testResponsesAreEqualWithDifferentName() {
    let code1 = Response.Code(200, "OK")
    let code2 = Response.Code(200, "OK-ish")
    assert(code1, doesNotEqual: code2)
  }
}
