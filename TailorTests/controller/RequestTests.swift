import XCTest
import Tailor
import TailorTesting

class RequestTests: XCTestCase, TailorTestable {
  var requestString = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
  let clientAddress = "1.2.3.4"
  
  var request : Request { get { return Request(clientAddress: clientAddress, data: requestData) } }
  var requestData : NSData { get { return NSData(bytes: requestString.utf8) } }
  
  override func setUp() {
    super.setUp()
    setUpTestCase()
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }
  }
  
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
  
  func testInitializationRemovesLeadingWhiteSpaceFromHeaderValues() {
    requestString = requestString.stringByReplacingOccurrencesOfString("header value", withString: " \theader value 2 ")
    let value = request.headers["X-Custom-Field"]
    assert(value, equals: "header value 2 ")
  }
  
  func testInitializationWithContinuationLineKeepsValueTogether() {
    requestString = requestString.stringByReplacingOccurrencesOfString("header value", withString: "header\r\n    value 2")
    let value = request.headers["X-Custom-Field"]
    assert(value, equals: "header value 2")
  }
  
  func testInitializationWithContinuationLineInCookieKeepsValueTogether() {
    requestString = requestString.stringByReplacingOccurrencesOfString("key3=value3", withString: "key3=value3\r\n + value4")
    let value = request.cookies["key3"]
    assert(value, equals: "value3 + value4")
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
      
      let data = NSData(bytes: "this is a log".utf8)
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
    
    assert(decoded.keys.count, equals: 2)
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
    assert(Array(decoded.keys), equals: ["key1", "key%1"])
  }
  
  func testParseTimeCanParseRfc822Format() {
    let timestamp = Request.parseTime("Sun, 06 Nov 1994 08:49:37 GMT")
    assert(timestamp?.year, equals: 1994)
    assert(timestamp?.month, equals: 11)
    assert(timestamp?.day, equals: 6)
    assert(timestamp?.hour, equals: 8)
    assert(timestamp?.minute, equals: 49)
    assert(timestamp?.second, equals: 37)
    assert(timestamp?.timeZone.name, equals: "GMT")
  }
  
  func testParseTimeCanParseRfc850Format() {
    let timestamp = Request.parseTime("Sunday, 06-Nov-94 08:49:37 GMT")
    assert(timestamp?.year, equals: 1994)
    assert(timestamp?.month, equals: 11)
    assert(timestamp?.day, equals: 6)
    assert(timestamp?.hour, equals: 8)
    assert(timestamp?.minute, equals: 49)
    assert(timestamp?.second, equals: 37)
    assert(timestamp?.timeZone.name, equals: "GMT")
  }
  
  func testParseTimeCanParsePosixFormat() {
    let timestamp = Request.parseTime("Sun Nov  6 08:49:37 1994")
    assert(timestamp?.year, equals: 1994)
    assert(timestamp?.month, equals: 11)
    assert(timestamp?.day, equals: 6)
    assert(timestamp?.hour, equals: 8)
    assert(timestamp?.minute, equals: 49)
    assert(timestamp?.second, equals: 37)
    assert(timestamp?.timeZone.name, equals: TimeZone.systemTimeZone().name)
  }
  
  //MARK: - Test Helpers
  
  func testInitializerCanInitializeRequestInfo() {
    let params = ["key1": "value1", "key2": "value2_value3"]
    let request = Request(clientAddress: "127.0.0.1", method: "POST", parameters: params, path: "/home")
    assert(request.fullPath, equals: "/home")
    assert(request.bodyText, equals: "key1=value1&key2=value2_value3")
    assert(request.requestParameters, equals: params, message: "sets request parameters")
    assert(request.method, equals: "POST", message: "sets method")
    assert(request.clientAddress, equals: "127.0.0.1", message: "sets client address")
  }
  
  func testInitializerSanitizesReservedCharactersInParameters() {
    let params = ["key1": "value1", "key2/key3": "value2&value3"]
    let request = Request(clientAddress: "127.0.0.1", method: "POST", parameters: params, path: "/home")
    assert(request.fullPath, equals: "/home")
    assert(request.bodyText, equals: "key1=value1&key2%2Fkey3=value2%26value3")
    assert(request.requestParameters, equals: params, message: "sets request parameters")
    assert(request.method, equals: "POST", message: "sets method")
    assert(request.clientAddress, equals: "127.0.0.1", message: "sets client address")
  }
  
  func testInitializerWithGetRequestPutsQueryStringInPath() {
    let params = ["key1": "value1", "key2/key3": "value2&value3"]
    let request = Request(clientAddress: "127.0.0.1", method: "GET", parameters: params, path: "/home")
    assert(request.fullPath, equals: "/home?key1=value1&key2%2Fkey3=value2%26value3", message: "includes the query string in the path")
    assert(request.bodyText, equals: "", message: "leaves the body blank")
    assert(request.requestParameters, equals: params, message: "sets request parameters")
    assert(request.method, equals: "GET", message: "sets method")
    assert(request.clientAddress, equals: "127.0.0.1", message: "sets client address")
  }
  
  func testInitializerCanInitializeSessionInfo() {
    Application.start()
    let request = Request(sessionData: ["mobile": "1"])
    let session = request.session
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
  
  //MARK: - Content Preferences
  
  func testContentPreferenceOptionFromHeaderWithSimpleOptionSetsTypeAndQuality() {
    let option = Request.ContentPreference.Option(fromHeader: "en-US")
    assert(option.type, equals: "en-US")
    assert(option.subtype, equals: "")
    assert(option.flags, equals: [:])
    assert(option.quality, equals: 1)
  }
  
  func testContentPreferenceOptionFromHeaderWithQualitySetsQuality() {
    let option = Request.ContentPreference.Option(fromHeader: "en-US;q=0.5")
    assert(option.type, equals: "en-US")
    assert(option.quality, equals: 0.5)
    assert(option.flags, equals: [:])
  }
  
  func testContentPreferenceOptionFromHeaderWithBadQualityFieldSetsQualityToZero() {
    let option = Request.ContentPreference.Option(fromHeader: "en-US;q=ok")
    assert(option.type, equals: "en-US")
    assert(option.quality, equals: 0)
    assert(option.flags, equals: [:])
  }
  
  func testContentPreferenceOptionFromHeaderWithFlagsSetsFlags() {
    let option = Request.ContentPreference.Option(fromHeader: "en-US;level=1;q=0.5;a=b")
    assert(option.type, equals: "en-US")
    assert(option.quality, equals: 0.5)
    assert(option.flags, equals: ["level": "1", "a": "b"])
  }
  
  func testContentPreferenceOptionWithSubtypeSetsSubtype() {
    let option = Request.ContentPreference.Option(fromHeader: "application/xml;q=0.2")
    assert(option.type, equals: "application")
    assert(option.subtype, equals: "xml")
  }
  
  func testContentPreferenceOptionFromHeaderTrimsSpaces() {
    let option = Request.ContentPreference.Option(fromHeader: " application/xml ;q=0.9")
    assert(option.type, equals: "application")
    assert(option.subtype, equals: "xml")
  }

  
  func testContentPreferenceOptionMatchesCompleteMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "application/xml")
    assert(option.matches("application/xml"))
  }
  
  func testContentPreferenceOptionDoesNotMatchDifferentSubtype() {
    let option = Request.ContentPreference.Option(fromHeader: "application/xml")
    assert(!option.matches("application/html"))
  }
  
  func testContentPreferenceOptionMatchLevelWithWildcardSubtypeIsMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "application/*")
    assert(option.matches("application/xml"))
  }
  
  func testContentPreferenceOptionMatchLevelWithFullWildcardIsMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "*/*")
    assert(option.matches("application/xml"))
  }
  
  func testContentPreferenceOptionWithNoSubtypeWithMatchIsMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "en")
    assert(option.matches("en"))
  }
  
  func testContentPreferenceOptionWithNoSubtypeWithWildcardIsMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "*")
    assert(option.matches("en"))
  }
  
  func testContentPreferenceOptionWithNoSubtypeWithMismatchIsNotMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "es")
    assert(!option.matches("en"))
  }
  
  func testContentPreferenceOptionWithAllFlagsMatchingIsMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "application/xml; a=b; c=d")
    assert(option.matches("application/xml; c=d; a=b"))
  }
  
  func testContentPreferenceOptionWithFlagsMissingIsNotMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "application/xml; a=b; c=d")
    assert(!option.matches("application/xml; c=d"))
  }
  
  func testContentPreferenceOptionWithWrongFlagValueIsNotMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "application/xml; a=b; c=d")
    assert(!option.matches("application/xml; c=d; a=f"))
  }
  
  func testContentPreferenceOptionWithExtraFlagValueIsMatch() {
    let option = Request.ContentPreference.Option(fromHeader: "application/xml; a=b; c=d")
    assert(option.matches("application/xml; c=d; a=b; e=f"))
  }
  
  func testContentPreferenceOptionWithSameInformationAreEqual() {
    let option1 = Request.ContentPreference.Option(type: "a", subtype: "b", flags: ["c": "d"], quality: 0.4)
    let option2 = Request.ContentPreference.Option(type: "a", subtype: "b", flags: ["c": "d"], quality: 0.4)
    assert(option1, equals: option2)
  }
  
  func testContentPreferenceOptionWithDifferentTypesAreNotEqual() {
    let option1 = Request.ContentPreference.Option(type: "a", subtype: "b", flags: ["c": "d"], quality: 0.4)
    let option2 = Request.ContentPreference.Option(type: "b", subtype: "b", flags: ["c": "d"], quality: 0.4)
    assert(option1, doesNotEqual: option2)
  }
  
  func testContentPreferenceOptionWithDifferentSubtypesAreNotEqual() {
    let option1 = Request.ContentPreference.Option(type: "a", subtype: "b", flags: ["c": "d"], quality: 0.4)
    let option2 = Request.ContentPreference.Option(type: "a", subtype: "c", flags: ["c": "d"], quality: 0.4)
    assert(option1, doesNotEqual: option2)
  }
  
  func testContentPreferenceOptionWithDifferentFlagsAreNotEqual() {
    let option1 = Request.ContentPreference.Option(type: "a", subtype: "b", flags: ["c": "d"], quality: 0.4)
    let option2 = Request.ContentPreference.Option(type: "b", subtype: "b", flags: ["c": "e"], quality: 0.4)
    assert(option1, doesNotEqual: option2)
  }
  
  func testContentPreferenceOptionWithDifferentQualitiesAreNotEqual() {
    let option1 = Request.ContentPreference.Option(type: "a", subtype: "b", flags: ["c": "d"], quality: 0.4)
    let option2 = Request.ContentPreference.Option(type: "b", subtype: "b", flags: ["c": "d"], quality: 0.3)
    assert(option1, doesNotEqual: option2)
  }
  
  func testContentPreferenceFromHeaderParsesOptions() {
    let preference = Request.ContentPreference(fromHeader: "application/html, application/xml")
    assert(preference.options, equals: [
      Request.ContentPreference.Option(type: "application", subtype: "html"),
      Request.ContentPreference.Option(type: "application", subtype: "xml")
    ])
  }
  
  func testContentPreferenceFromHeaderPutsHighQualityOptionsBeforeLowQualityOptions() {
    let preference = Request.ContentPreference(fromHeader: "application/html;q=0.5, application/xml,*/*;q=0.4")
    
    assert(preference.options, equals: [
      Request.ContentPreference.Option(type: "application", subtype: "xml", quality: 1),
      Request.ContentPreference.Option(type: "application", subtype: "html", quality: 0.5),
      Request.ContentPreference.Option(type: "*", subtype: "*", quality: 0.4),
    ])
  }
  
  func testContentPreferenceBestMatchWithOneValueWithAcceptableValueReturnsValue() {
    let preference = Request.ContentPreference(options: [
      .init(type: "application", subtype: "xml"),
      .init(type: "application", subtype: "html"),
      .init(type: "application", subtype: "*")
    ])
    assert(preference.bestMatch("application/xml"), equals: "application/xml")
    assert(preference.bestMatch("application/html"), equals: "application/html")
    assert(preference.bestMatch("application/json"), equals: "application/json")
  }
  
  func testContentPreferenceBestMatchWithMultipleValuesReturnsValueWithHighestMatch() {
    
    let preference = Request.ContentPreference(options: [
      .init(type: "application", subtype: "xml"),
      .init(type: "application", subtype: "html"),
      .init(type: "application", subtype: "*")
      ])
    assert(preference.bestMatch("application/html", "application/xml"), equals: "application/xml")
    assert(preference.bestMatch("application/json", "application/html"), equals: "application/html")
    assert(preference.bestMatch("application/foo", "application/json"), equals: "application/foo")
    assert(preference.bestMatch("text/plain", "application/json"), equals: "application/json")
  }
  
  func testContentPreferenceBestMatchWithNoMatchReturnsNil() {
    
    let preference = Request.ContentPreference(options: [
      .init(type: "application", subtype: "xml"),
      .init(type: "application", subtype: "html"),
      .init(type: "application", subtype: "*")
      ])
    assert(isNil: preference.bestMatch("text/plain", "text/foo"))
  }
  
  func testContentPreferencesWithSameOptionsAreEqual() {
    let preference1 = Request.ContentPreference(options: [
      .init(type: "application", subtype: "xml"),
      .init(type: "application", subtype: "html"),
      .init(type: "application", subtype: "*")
      ])
    
    let preference2 = Request.ContentPreference(options: [
      .init(type: "application", subtype: "xml"),
      .init(type: "application", subtype: "html"),
      .init(type: "application", subtype: "*")
      ])
    assert(preference1, equals: preference2)
  }
  
  func testConetnPreferencesWithDifferentOptionsAreNotEqual() {
    let preference1 = Request.ContentPreference(options: [
      .init(type: "application", subtype: "xml"),
      .init(type: "application", subtype: "html"),
      .init(type: "application", subtype: "*")
      ])
    
    let preference2 = Request.ContentPreference(options: [
      .init(type: "application", subtype: "xml"),
      .init(type: "application", subtype: "html"),
      .init(type: "application", subtype: "json")
      ])
    assert(preference1, doesNotEqual: preference2)
    
  }
}
