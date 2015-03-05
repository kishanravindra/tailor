import XCTest

class RequestTests: XCTestCase {
  var requestString = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
  let clientAddress = "1.2.3.4"
  
  var request : Request { get { return Request(clientAddress: clientAddress, data: requestData) } }
  var requestData : NSData { get { return requestString.dataUsingEncoding(NSUTF8StringEncoding)! } }
  
  //MARK: - Initialization
  
  func testInitializationSetsClientAddressOnRequest() {
    XCTAssertEqual(request.clientAddress, "1.2.3.4", "sets client address based on initialization")
  }
  
  func testInitializationSetsMethod() {
    XCTAssertEqual(request.method, "GET", "sets method to GET for GET request")
    requestString = requestString.stringByReplacingOccurrencesOfString("GET", withString: "POST")
    XCTAssertEqual(request.method, "POST", "sets method to POST for POST request")
    requestString = ""
    XCTAssertEqual(request.method, "GET", "sets method to GET for empty request")
  }
  
  func testInitializationSetsPath() {
    XCTAssertEqual(request.path, "/test/path", "sets path based on header")
    requestString = ""
    XCTAssertEqual(request.path, "/", "sets path to root for empty request")
  }
  
  func testInitializationSetsHttpVersion() {
    XCTAssertEqual(request.version, "1.1", "sets method to 1.1 for 1.1 request")
    requestString = requestString.stringByReplacingOccurrencesOfString("1.1", withString: "1.0")
    XCTAssertEqual(request.version, "1.0", "sets method to 1.0 for 1.0 request")
    requestString = ""
    XCTAssertEqual(request.version, "1.1", "sets method to 1.1 for empty request")
  }
  
  func testInitializationRemovesQueryStringFromPath() {
    requestString = requestString.stringByReplacingOccurrencesOfString("/test/path", withString: "/test/path?count=5")
    XCTAssertEqual(request.path, "/test/path", "removes query string from path")
    XCTAssertEqual(request.fullPath, "/test/path?count=5", "leaves query string in full path")
  }
  
  func testInitializationSetsHeaders() {
    let headers = request.headers
    let header1 = headers["X-Custom-Field"]
    let header2 = headers["Referer"]
    
    XCTAssertNotNil(header1, "sets X-Custom-Field header")
    if header1 != nil {
      XCTAssertEqual(header1!, "header value", "sets X-Custom-Field header to correct value")
    }
    
    
    XCTAssertNotNil(header2, "sets Referer header")
    if header2 != nil {
      XCTAssertEqual(headers["Referer"]!, "searchtheweb.com", "sets Referer header to correct value")
    }
  }
  
  func testInitializationSetsCookies() {
    let cookies = request.cookies
    
    if let value = cookies["key1"] {
      XCTAssertEqual(value, "value1", "sets cookie for key1")
    }
    else {
      XCTFail("sets cookie for key1")
    }
    
    if let value = cookies["key2"] {
      XCTAssertEqual(value, "value2", "sets cookie for key2")
    }
    else {
      XCTFail("sets cookie for key2")
    }
    
    if let value = cookies["key3"] {
      XCTAssertEqual(value, "value3", "sets cookie for key3")
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
      XCTAssertEqual(param!, "5", "sets request parameter to correct value")
    }
  }
  
  //MARK: - Body Parsing
  
  func testBodyTextGetsStringFromBodyData() {
    XCTAssertEqual(request.bodyText, "Request Body", "gets body text from the request")
  }
  
  func testParseRequestParametersGetsParametersFromQueryString() {
    requestString = requestString.stringByReplacingOccurrencesOfString("/test/path", withString: "/test/path?count=5&id=6")
    let params = request.requestParameters
    
    if let value = params["count"] {
      XCTAssertEqual(value, "5", "sets count parameter")
    }
    else {
      XCTFail("sets count parameter")
    }
    
    if let value = params["id"] {
      XCTAssertEqual(value, "6", "sets id parameter")
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
      XCTAssertEqual(value, "5", "sets count parameter")
    }
    else {
      XCTFail("sets count parameter")
    }
    
    if let value = params["id"] {
      XCTAssertEqual(value, "6", "sets id parameter")
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
      XCTAssertEqual(value, "value1", "sets param1")
    }
    else {
      XCTFail("sets param1")
    }
    
    if let value = params["param2"] {
      XCTAssertEqual(value, "value2", "sets param2")
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
      XCTAssertEqual(value, "value1", "sets param1")
    }
    else {
      XCTFail("sets param1")
    }
    
    if let file = request.uploadedFiles["param2"] {
      if let value = file["contentType"] as? String {
        XCTAssertEqual(value, "text/plain", "sets content type")
      }
      else {
        XCTFail("sets content type")
      }
      if let value = file["data"] as? NSData {
        let data = "this is a log".dataUsingEncoding(NSUTF8StringEncoding)!
        XCTAssertEqual(value, data, "sets data")
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
    XCTAssertEqual(matches.count, 2, "gets two matches")
    XCTAssertEqual(matches[0], "Content-Type", "gets the first match")
    XCTAssertEqual(matches[1], "text/plain", "gets the second match")
  }
  
  func testExtractWithPatternGetsEmptyListForNoMatch() {
    let matches = Request.extractWithPattern(" Content-Type: text/plain", pattern: "^([\\w-]*): (.*)$")
    XCTAssertEqual(matches.count, 0, "gets no matches")
  }
  
  func testDecodeQueryStringGetsParameters() {
    let queryString = "key1=value1&key2=value%3da+b"
    let decoded = Request.decodeQueryString(queryString)
    
    if let value = decoded["key1"] {
      XCTAssertEqual(value, "value1", "gets simple param")
    }
    else {
      XCTFail("gets simple param")
    }
    
    if let value = decoded["key2"] {
      XCTAssertEqual(value, "value=a b", "decodes param with escapes")
    }
    else {
      XCTFail("decodes param with escapes")
    }
  }
  
  func testDecodedStringGetsEmptyStringWithoutEqualSign() {
    let queryString = "key1&key2"
    let decoded = Request.decodeQueryString(queryString)
    
    if let value = decoded["key1"] {
      XCTAssertEqual(value, "", "gets key1")
    }
    else {
      XCTFail("gets simple param")
    }
    
    if let value = decoded["key2"] {
      XCTAssertEqual(value, "", "gets key2")
    }
    else {
      XCTFail("gets key2")
    }
  }
  
  //MARK: - Test Helpers
  
  func testInitializerCanInitializeRequestInfo() {
    let params = ["key1": "value1", "key2": "value2"]
    let request = Request(clientAddress: "127.0.0.1", method: "POST", parameters: params)
    XCTAssertEqual(request.requestParameters, params, "sets request parameters")
    XCTAssertEqual(request.method, "POST", "sets method")
    XCTAssertEqual(request.clientAddress, "127.0.0.1", "sets client address")
  }
  
  func testInitializerCanInitializeSessionInfo() {
    TestApplication.start()
    let request = Request(sessionData: ["mobile": "1"])
    let session = Session(request: request)
    let value = session["mobile"]
    XCTAssertNotNil(value, "sets session value")
    if value != nil { XCTAssertEqual(value!, "1", "sets session value") }
  }
  
  func testInitializerCanInitializeCookieInfo() {
    let request = Request(cookies: ["tracker": "test.com"])
    let cookieValue = request.cookies["tracker"]
    XCTAssertNotNil(cookieValue)
    if cookieValue != nil { XCTAssertEqual(cookieValue!, "test.com", "sets cookie value") }
  }
}
