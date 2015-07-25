import XCTest
import Tailor
import TailorTesting

class RequestTests: TailorTestCase {
  var requestString = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
  let clientAddress = "1.2.3.4"
  
  var request : Request { get { return Request(clientAddress: clientAddress, data: requestData) } }
  var requestData : NSData { get { return requestString.dataUsingEncoding(NSUTF8StringEncoding)! } }
  
  //MARK: - Initialization
  
  func testInitializationSetsClientAddressOnRequest() {
    assert(request.clientAddress, equals: "1.2.3.4", message: "sets client address based on initialization")
  }
  
  func testInitializationSetsMethod() {
    assert(request.method, equals: "GET", message: "sets method to GET for GET request")
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    assert(request.method, equals: "POST", message: "sets method to POST for POST request")
    requestString = ""
    assert(request.method, equals: "GET", message: "sets method to GET for empty request")
  }
  
  func testInitializationSetsPath() {
    assert(request.path, equals: "/test/path", message: "sets path based on header")
    requestString = ""
    assert(request.path, equals: "/", message: "sets path to root for empty request")
  }
  
  func testInitializationSetsHttpVersion() {
    assert(request.version, equals: "1.1", message: "sets method to 1.1 for 1.1 request")
    requestString = requestString.stringByReplacingOccurrencesOfString("1.1", withString: "1.0")
    assert(request.version, equals: "1.0", message: "sets method to 1.0 for 1.0 request")
    requestString = ""
    assert(request.version, equals: "1.1", message: "sets method to 1.1 for empty request")
  }
  
  func testInitializationRemovesQueryStringFromPath() {
    requestString = requestString.stringByReplacingOccurrencesOfString("/test/path", withString: "/test/path?count=5")
    assert(request.path, equals: "/test/path", message: "removes query string from path")
    assert(request.fullPath, equals: "/test/path?count=5", message: "leaves query string in full path")
  }
  
  func testInitializationSetsHeaders() {
    let headers = request.headers
    assert(headers["X-Custom-Field"], equals: "header value", message: "sets X-Custom-Field header to correct value")
    assert(headers["Referer"], equals: "searchtheweb.com", message: "sets Referer header to correct value")
  }
  
  func testInitializationSetsCookies() {
    let cookies = request.cookies
    
    assert(cookies["key1"], equals: "value1", message: "sets cookie for key1")
    assert(cookies["key2"], equals: "value2", message: "sets cookie for key2")
    assert(cookies["key3"], equals: "value3", message: "sets cookie for key3")
  }
  
  func testInitializationSetsRequestParameters() {
    requestString = requestString.stringByReplacingOccurrencesOfString("/test/path", withString: "/test/path?count=5")
    let param = request.requestParameters["count"]

    assert(param, equals: "5", message: "sets request parameter to correct value")
  }
  
  func testInitializationWithBadlyEncodedDataSetsEmptyHeaders() {
    let request = Request(clientAddress: clientAddress, data: NSData(bytes: [0xD8,0]))
    assert(request.headers.isEmpty)
  }
  
  //MARK: - Body Parsing
  
  func testBodyTextGetsStringFromBodyData() {
    assert(request.bodyText, equals: "Request Body", message: "gets body text from the request")
  }
  
  func testBodyTextWithBadlyEncodedDataIsBlank() {
    let requestData = NSData(bytes: [0x0D, 0x0A, 0x0D, 0x0A, 0xD8, 0x00])
    let request = Request(clientAddress: clientAddress, data: requestData)
    assert(request.bodyText, equals: "")
  }
  
  func testParseRequestParametersGetsParametersFromQueryString() {
    requestString = requestString.stringByReplacingOccurrencesOfString("/test/path", withString: "/test/path?count=5&id=6")
    let params = request.requestParameters
    
    assert(params["count"], equals: "5", message: "sets count parameter")
    assert(params["id"], equals: "6", message: "sets id parameter")
  }
  
  func testParseRequestParametersGetsParametersFromPostRequest() {
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    requestString = requestString.stringByReplacingOccurrencesOfString("X-Custom-Field: header value", withString: "Content-Type: application/x-www-form-urlencoded")
    requestString = requestString.stringByReplacingOccurrencesOfString("Request Body", withString: "count=5&id=6")
    let params = request.requestParameters
    
    assert(params["count"], equals: "5", message: "sets count parameter")
    assert(params["id"], equals: "6", message: "sets id parameter")
  }
  
  func testParseRequestParametersGetsParametersFromMultipartForm() {
    let boundary = "----TestFormBoundaryK7Slx2O95dkvjQ14"
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    requestString = requestString.stringByReplacingOccurrencesOfString("X-Custom-Field: header value", withString: "Content-Type: multipart/form-data; boundary=\(boundary)")
    requestString = requestString.stringByReplacingOccurrencesOfString("Request Body", withString: "--\(boundary)\r\nContent-Disposition: form-data; name=\"param1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param2\"\r\n\r\nvalue2\r\n--\(boundary)--")
    let params = request.requestParameters

    assert(params["param1"], equals: "value1", message: "sets param1")
    assert(params["param2"], equals: "value2", message: "sets param2")
  }
  
  func testParseRequestWithMultipartFormWithBoundariesGetsEmptyParameters() {
    let boundary = "----TestFormBoundaryK7Slx2O95dkvjQ14"
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    requestString = requestString.stringByReplacingOccurrencesOfString("X-Custom-Field: header value", withString: "Content-Type: multipart/form-data")
    requestString = requestString.stringByReplacingOccurrencesOfString("Request Body", withString: "--\(boundary)\r\nContent-Disposition: form-data; name=\"param1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param2\"\r\n\r\nvalue2\r\n--\(boundary)--")
    let params = request.requestParameters
    assert(params.isEmpty)
  }
  
  func testParseRequestParametersGetsFileFromMultipartForm() {
    let boundary = "----TestFormBoundaryK7Slx2O95dkvjQ14"
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    requestString = requestString.stringByReplacingOccurrencesOfString("X-Custom-Field: header value", withString: "Content-Type: multipart/form-data; boundary=\(boundary)")
    requestString = requestString.stringByReplacingOccurrencesOfString("Request Body", withString: "--\(boundary)\r\nContent-Disposition: form-data; name=\"param1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param2\"; filename=\"record.log\"\r\nContent-Type: text/plain\r\n\r\nthis is a log\r\n--\(boundary)--")
    let params = request.requestParameters
    
    assert(params["param1"], equals: "value1", message: "sets param1")
    
    if let file = request.uploadedFiles["param2"] {
      assert(file["contentType"] as? String, equals: "text/plain", message: "sets content type")
      
      let data = "this is a log".dataUsingEncoding(NSUTF8StringEncoding)!
      assert(file["data"] as? NSData, equals: data, message: "sets data")
    }
    else {
      XCTFail("sets param2")
    }
  }

  //MARK: - Helper Methods
  
  func testExtractWithPatternGetsPiecesOfLine() {
    let matches = Request.extractWithPattern("Content-Type: text/plain", pattern: "^([\\w-]*): (.*)$")
    assert(matches.count, equals: 2, message: "gets two matches")
    assert(matches[0], equals: "Content-Type", message: "gets the first match")
    assert(matches[1], equals: "text/plain", message: "gets the second match")
  }
  
  func testExtractWithPatternGetsEmptyListForNoMatch() {
    let matches = Request.extractWithPattern(" Content-Type: text/plain", pattern: "^([\\w-]*): (.*)$")
    assert(matches.count, equals: 0, message: "gets no matches")
  }
  
  func testExtractWithPatternWithInvalidPatternReturnsEmptyArray() {
    let matches = Request.extractWithPattern(" Content-Type: text/plain", pattern: "^([\\w-]*): (.*")
    assert(matches.count, equals: 0, message: "gets no matches")
  }
  
  func testDecodeQueryStringGetsParameters() {
    let queryString = "key1=value1&key2=value%3da+b"
    let decoded = Request.decodeQueryString(queryString)
    
    assert(decoded["key1"], equals: "value1", message: "gets simple param")
    assert(decoded["key2"], equals: "value=a b", message: "decodes param with escapes")
  }
  
  func testDecodedStringGetsEmptyStringWithoutEqualSign() {
    let queryString = "key1&key2"
    let decoded = Request.decodeQueryString(queryString)
    
    assert(decoded["key1"], equals: "", message: "gets key1")
    assert(decoded["key2"], equals: "", message: "gets key2")
  }
  
  func testDecodeQueryStringLeavesBadEscapeValueUnescaped() {
    let queryString = "key1=1&key%1=2"
    let decoded = Request.decodeQueryString(queryString)
    assert(decoded.keys.array, equals: ["key1", "key%1"])
  }
  
  //MARK: - Test Helpers
  
  func testInitializerCanInitializeRequestInfo() {
    let params = ["key1": "value1", "key2": "value2"]
    let request = Request(clientAddress: "127.0.0.1", method: "POST", parameters: params)
    assert(request.requestParameters, equals: params, message: "sets request parameters")
    assert(request.method, equals: "POST", message: "sets method")
    assert(request.clientAddress, equals: "127.0.0.1", message: "sets client address")
  }
  
  func testInitializerCanInitializeSessionInfo() {
    Application.start()
    let request = Request(sessionData: ["mobile": "1"])
    let session = Session(request: request)
    let value = session["mobile"]
    XCTAssertNotNil(value, "sets session value")
    if value != nil { assert(value!, equals: "1", message: "sets session value") }
  }
  
  func testInitializerCanInitializeCookieInfo() {
    let request = Request(cookies: ["tracker": "test.com"])
    let cookieValue = request.cookies["tracker"]
    XCTAssertNotNil(cookieValue)
    if cookieValue != nil { assert(cookieValue!, equals: "test.com", message: "sets cookie value") }
  }
  
  func testInitializeWithNonUtf8ParameterTranslatesToEmptyString() {
    let data = NSData(bytes: [0xD8, 0x00])
    let badString = NSString(data: data, encoding: NSUTF16BigEndianStringEncoding)! as String
    let request = Request(parameters: ["key": badString])
    assert(request.requestParameters["key"], equals: "")
  }
  
  //MARK: - Equality
  
  func testRequestsAreEqualWithSameData() {
    let request1 = Request(parameters: ["a": "b"])
    let request2 = Request(parameters: ["a": "b"])
    assert(request1, equals: request2)
  }
  func testRequestsAreUnequalWithDifferentData() {
    let request1 = Request(parameters: ["a": "b"])
    let request2 = Request(parameters: ["a": "c"])
    assert(request1, doesNotEqual: request2)
  }
}
