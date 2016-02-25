import Tailor
import TailorTesting
import Foundation

struct TestHttpMessageType: TailorTestable {
  struct Message: HttpMessageType {
    var statusLine: String
    var headers: [String:String]
    var cookies: CookieJar
    var bodyData: NSData
    var bodyOnly = false
    var hasDefinedLength = true
    var setsCookies = false

    init() {
      self.init(statusLine: "", headers: [:], cookies: CookieJar(), bodyData: NSData())
    }

    init(statusLine: String, headers: [String:String], cookies: CookieJar, bodyData: NSData) {
      self.statusLine = statusLine
      self.headers = headers
      self.cookies = cookies
      self.bodyData = bodyData
      self.setsCookies = false
    }
  }

  let requestText = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"

  var allTests: [(String, () throws -> Void)] { return [
    ("testInitializationWithDataForRequestParsesRequest", testInitializationWithDataForRequestParsesRequest),
    ("testInitializationWithBadlyEncodedDataSetsEmptyHeaders", testInitializationWithBadlyEncodedDataSetsEmptyHeaders),
    ("testInitializationWithContinuationLineKeepsValueTogether", testInitializationWithContinuationLineKeepsValueTogether),
    ("testInitializationWithContinuationLineInCookieKeepsValueTogether", testInitializationWithContinuationLineInCookieKeepsValueTogether),
    ("testBodyTextGetsStringFromBodyData", testBodyTextGetsStringFromBodyData),
    ("testBodyTextWithBadlyEncodedDataIsBlank", testBodyTextWithBadlyEncodedDataIsBlank),
    ("testAppendStringAppendsToBody", testAppendStringAppendsToBody),
    ("testAppendDataAppendsToBody", testAppendDataAppendsToBody),
    ("testDataContainsStatusLine", testDataContainsStatusLine),
    ("testDataContainsCustomHeaders", testDataContainsCustomHeaders),
    ("testDataContainsDefaultHeaders", testDataContainsDefaultHeaders),
    ("testDataForResponseWithUndefinedLengthHasNoLengthHeader", testDataForResponseWithUndefinedLengthHasNoLengthHeader),
    ("testDataForResponseWithBodyOnlyContainsOnlyTheBody", testDataForResponseWithBodyOnlyContainsOnlyTheBody),
    ("testDataAllowsSpecialHeadersToOverrideDefaults", testDataAllowsSpecialHeadersToOverrideDefaults),
    ("testDataContainsCookieHeaders", testDataContainsCookieHeaders),
    ("testDataWithSetCookieFlagContainsSetCookieHeaders", testDataWithSetCookieFlagContainsSetCookieHeaders),
    ("testDataContainsBody", testDataContainsBody),
    ("testCopyDoesNotShareChanges", testCopyDoesNotShareChanges),
    ("testClearBodyClearsBody", testClearBodyClearsBody),
  ]}

  func setUp() {
    setUpTestCase()
  }

  func testInitializationWithDataForRequestParsesRequest() {
    let requestText = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
    let message = Message(data: NSData(bytes: requestText.utf8))
    assert(message.statusLine, equals: "GET /test/path HTTP/1.1")
    assert(message.headers, equals: [
      "X-Custom-Field": "header value",
      "Referer": "searchtheweb.com"
    ])

    assert(message.cookies.cookies, equals: [
      Cookie(key: "key1", value: "value1"),
      Cookie(key: "key2", value: "value2"),
      Cookie(key: "key3", value: "value3")
    ])

    assert(message.bodyData, equals: NSData(bytes: "Request Body".utf8))
  }
  
  func testInitializationWithBadlyEncodedDataSetsEmptyHeaders() {
    let message = Message(data: NSData(bytes: [0xD8,0]))
    assert(message.headers.isEmpty)
  }
  
  func testInitializationRemovesLeadingWhiteSpaceFromHeaderValues() {
    let message = Message(data: NSData(bytes: requestText.utf8))
    let value = message.headers["X-Custom-Field"]
    assert(value, equals: "header value 2 ")
  }
  
  func testInitializationWithContinuationLineKeepsValueTogether() {
    let requestText = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header\r\n    value 2\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
    let message = Message(data: NSData(bytes: requestText.utf8))
    let value = message.headers["X-Custom-Field"]
    assert(value, equals: "header value 2")
  }
  
  func testInitializationWithContinuationLineInCookieKeepsValueTogether() {
    let requestText = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n + value4\r\n\r\nRequest Body"
    let message = Message(data: NSData(bytes: requestText.utf8))
    let value = message.cookies["key3"]
    assert(value, equals: "value3 + value4")
  }

  //MARK: - Message Body
  
  func testBodyTextGetsStringFromBodyData() {
    let message = Message(data: NSData(bytes: requestText.utf8))
    assert(message.bodyText, equals: "Request Body", message: "gets body text from the request")
  }
  
  func testBodyTextWithBadlyEncodedDataIsBlank() {
    let data = NSData(bytes: [0x0D, 0x0A, 0x0D, 0x0A, 0xD8, 0x00])
    let message = Message(data: data)
    assert(message.bodyText, equals: "")
  }

  func testAppendStringAppendsToBody() {
    var message = Message()
    message.appendString("Test")
    message.appendString("String")
    let data = NSData(bytes: "TestString".utf8)
    assert(message.bodyData, equals: data, message: "sets the body data to the combined strings")
  }
  
  func testAppendDataAppendsToBody() {
    var message = Message()
    let bytes = [1,2,3,4]
    let data = NSData(bytes: bytes, length: bytes.count)
    message.appendData(data)
    assert(message.bodyData, equals: data, message: "sets the body data to the data given")
  }
  
  func testCopyDoesNotShareChanges() {
    var message = Message()
    let message2 = message
    message.appendString("Hello")
    assert(message2.bodyText, equals: "")
  }
  
  func testClearBodyClearsBody() {
    var message = Message(data: NSData(bytes: requestText.utf8))
    message.clearBody()
    assert(message.bodyData.length, equals: 0)
  }

  //MARK: - Message Data

  func linesFromData(message: HttpMessageType) -> [String] {
    let responseString = NSString(data: message.data, encoding: NSUTF8StringEncoding)
    return responseString!.componentsSeparatedByString("\r\n") as [String]
  }
  
  func testDataContainsStatusLine() {
    let message = Message(data: NSData(bytes: requestText.utf8))
    let lines = self.linesFromData(message)
    assert(lines[0], equals: "GET /test/path HTTP/1.1", message: "response has HTTP intro line")
  }
  
  func testDataContainsCustomHeaders() {
    let message = Message(data: NSData(bytes: requestText.utf8))
    let lines = self.linesFromData(message)
    assert(lines.contains("X-Custom-Field: header value"), message: "has a custom header in the headers")
  }
  
  func testDataContainsDefaultHeaders() {
    let message = Message(data: NSData(bytes: requestText.utf8))
    let lines = self.linesFromData(message)
    assert(lines.contains("Content-Length: 12"), message: "has the body length as the content length header")
    assert(lines.contains("Content-Type: text/html; charset=UTF-8"))
    let date = Timestamp.now().inTimeZone("GMT").format(TimeFormat.Rfc822)
    assert(lines.contains("Date: \(date)"), message: "has the current time as the date header")
  }
  
  func testDataForResponseWithUndefinedLengthHasNoLengthHeader() {
    var message = Message(data: NSData(bytes: requestText.utf8))
    message.hasDefinedLength = false
    let lines = self.linesFromData(message)
    assert(!lines.contains("Content-Length: 12"), message: "has no content length header")
    assert(lines.contains("Content-Type: text/html; charset=UTF-8"))
  }
  
  func testDataForResponseWithBodyOnlyContainsOnlyTheBody() {
    var message = Message(data: NSData(bytes: requestText.utf8))
    message.bodyOnly = true
    let lines = self.linesFromData(message)
    assert(lines, equals: ["Request Body"])
  }
  
  func testDataAllowsSpecialHeadersToOverrideDefaults() {
    var message = Message(data: NSData(bytes: requestText.utf8))
    message.headers["Content-Length"] = "A"
    message.headers["Content-Type"] = "B"
    message.headers["Date"] = "C"
    let lines = self.linesFromData(message)
    
    assert(lines.contains("Content-Length: A"))
    assert(lines.contains("Content-Type: B"))
    assert(lines.contains("Date: C"))
    assert(!lines.contains("Content-Length: 24"), message: "does not have the default content length")
    assert(!lines.contains("Content-Type: text/html; charset=UTF-8"), message: "does not have the default content type")
    let date = Timestamp.now().inTimeZone("GMT").format(TimeFormat.Rfc822)
    assert(!lines.contains("Date: \(date)"), message: "does not have the current time as the date header")
  }
  
  func testDataContainsCookieHeaders() {
    let message = Message(data: NSData(bytes: requestText.utf8))
    let lines = self.linesFromData(message)
    print("Has lines: \(lines)")
    assert(lines.contains("Cookie: key1=value1; Path=/"))
    assert(lines.contains("Cookie: key2=value2; Path=/"))
    assert(lines.contains("Cookie: key3=value3; Path=/"))
  }
  
  func testDataWithSetCookieFlagContainsSetCookieHeaders() {
    var message = Message(data: NSData(bytes: requestText.utf8))
    message.setsCookies = true
    message.cookies["key2"] = "value!"
    message.cookies["key4"] = "value4"
    let lines = self.linesFromData(message)
    assert(lines.contains("Set-Cookie: key2=value!; Path=/"), message: "has a cookie header for a changed cookie")
    assert(lines.contains("Set-Cookie: key4=value4; Path=/"), message: "has a cookie header for a new cookie")
    assert(!lines.contains("Set-Cookie: key1=value1; Path=/"), message: "does not have a cookie header for an unchanged cookie")
  }
  
  func testDataContainsBody() {
    let message = Message(data: NSData(bytes: requestText.utf8))
    let lines = self.linesFromData(message)
    assert(lines.contains("Request Body"))
  }
}