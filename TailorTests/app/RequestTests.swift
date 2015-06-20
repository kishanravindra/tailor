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
    let header1 = headers["X-Custom-Field"]
    let header2 = headers["Referer"]
    
    XCTAssertNotNil(header1, "sets X-Custom-Field header")
    if header1 != nil {
      assert(header1!, equals: "header value", message: "sets X-Custom-Field header to correct value")
    }
    
    
    XCTAssertNotNil(header2, "sets Referer header")
    if header2 != nil {
      assert(headers["Referer"]!, equals: "searchtheweb.com", message: "sets Referer header to correct value")
    }
  }
  
  func testInitializationSetsCookies() {
    let cookies = request.cookies
    
    if let value = cookies["key1"] {
      assert(value, equals: "value1", message: "sets cookie for key1")
    }
    else {
      XCTFail("sets cookie for key1")
    }
    
    if let value = cookies["key2"] {
      assert(value, equals: "value2", message: "sets cookie for key2")
    }
    else {
      XCTFail("sets cookie for key2")
    }
    
    if let value = cookies["key3"] {
      assert(value, equals: "value3", message: "sets cookie for key3")
    }
    else {
      XCTFail("sets cookie for key3")
    }
  }
  
  func testInitializationSetsRequestParameters() {
    requestString = requestString.stringByReplacingOccurrencesOfString("/test/path", withString: "/test/path?count=5")
    let param = request.requestParameters["count"]

    XCTAssertNotNil(param, "sets request parameter")
    if param != nil {
      assert(param!, equals: "5", message: "sets request parameter to correct value")
    }
  }
  
  //MARK: - Body Parsing
  
  func testBodyTextGetsStringFromBodyData() {
    assert(request.bodyText, equals: "Request Body", message: "gets body text from the request")
  }
  
  func testParseRequestParametersGetsParametersFromQueryString() {
    requestString = requestString.stringByReplacingOccurrencesOfString("/test/path", withString: "/test/path?count=5&id=6")
    let params = request.requestParameters
    
    if let value = params["count"] {
      assert(value, equals: "5", message: "sets count parameter")
    }
    else {
      XCTFail("sets count parameter")
    }
    
    if let value = params["id"] {
      assert(value, equals: "6", message: "sets id parameter")
    }
    else {
      XCTFail("sets count parameter")
    }
  }
  
  func testParseRequestParametersGetsParametersFromPostRequest() {
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    requestString = requestString.stringByReplacingOccurrencesOfString("X-Custom-Field: header value", withString: "Content-Type: application/x-www-form-urlencoded")
    requestString = requestString.stringByReplacingOccurrencesOfString("Request Body", withString: "count=5&id=6")
    let params = request.requestParameters
    
    if let value = params["count"] {
      assert(value, equals: "5", message: "sets count parameter")
    }
    else {
      XCTFail("sets count parameter")
    }
    
    if let value = params["id"] {
      assert(value, equals: "6", message: "sets id parameter")
    }
    else {
      XCTFail("sets id parameter")
    }
  }
  
  func testParseRequestParametersGetsParametersFromMultipartForm() {
    let boundary = "----TestFormBoundaryK7Slx2O95dkvjQ14"
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    requestString = requestString.stringByReplacingOccurrencesOfString("X-Custom-Field: header value", withString: "Content-Type: multipart/form-data; boundary=\(boundary)")
    requestString = requestString.stringByReplacingOccurrencesOfString("Request Body", withString: "--\(boundary)\r\nContent-Disposition: form-data; name=\"param1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param2\"\r\n\r\nvalue2\r\n--\(boundary)--")
    let params = request.requestParameters

    if let value = params["param1"] {
      assert(value, equals: "value1", message: "sets param1")
    }
    else {
      XCTFail("sets param1")
    }
    
    if let value = params["param2"] {
      assert(value, equals: "value2", message: "sets param2")
    }
    else {
      XCTFail("sets param2")
    }
  }
  
  func testParseRequestParametersGetsFileFromMultipartForm() {
    let boundary = "----TestFormBoundaryK7Slx2O95dkvjQ14"
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    requestString = requestString.stringByReplacingOccurrencesOfString("X-Custom-Field: header value", withString: "Content-Type: multipart/form-data; boundary=\(boundary)")
    requestString = requestString.stringByReplacingOccurrencesOfString("Request Body", withString: "--\(boundary)\r\nContent-Disposition: form-data; name=\"param1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param2\"; filename=\"record.log\"\r\nContent-Type: text/plain\r\n\r\nthis is a log\r\n--\(boundary)--")
    let params = request.requestParameters
    
    if let value = params["param1"] {
      assert(value, equals: "value1", message: "sets param1")
    }
    else {
      XCTFail("sets param1")
    }
    
    if let file = request.uploadedFiles["param2"] {
      if let value = file["contentType"] as? String {
        assert(value, equals: "text/plain", message: "sets content type")
      }
      else {
        XCTFail("sets content type")
      }
      if let value = file["data"] as? NSData {
        let data = "this is a log".dataUsingEncoding(NSUTF8StringEncoding)!
        assert(value, equals: data, message: "sets data")
      }
      else {
        XCTFail("sets data")
      }
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
  
  func testDecodeQueryStringGetsParameters() {
    let queryString = "key1=value1&key2=value%3da+b"
    let decoded = Request.decodeQueryString(queryString)
    
    if let value = decoded["key1"] {
      assert(value, equals: "value1", message: "gets simple param")
    }
    else {
      XCTFail("gets simple param")
    }
    
    if let value = decoded["key2"] {
      assert(value, equals: "value=a b", message: "decodes param with escapes")
    }
    else {
      XCTFail("decodes param with escapes")
    }
  }
  
  func testDecodedStringGetsEmptyStringWithoutEqualSign() {
    let queryString = "key1&key2"
    let decoded = Request.decodeQueryString(queryString)
    
    if let value = decoded["key1"] {
      assert(value, equals: "", message: "gets key1")
    }
    else {
      XCTFail("gets simple param")
    }
    
    if let value = decoded["key2"] {
      assert(value, equals: "", message: "gets key2")
    }
    else {
      XCTFail("gets key2")
    }
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
