import XCTest
import Tailor
import TailorTesting
import Foundation

final class TestRequest: XCTestCase, TailorTestable {
  var requestString = ""
  let clientAddress = "1.2.3.4"
  
  var request : Request { get { return Request(clientAddress: clientAddress, data: requestData) } }
  var requestData : NSData { get { return NSData(bytes: requestString.utf8) } }
  
  //FIXME: Re-enable commented out tests
  var allTests: [(String, () throws -> Void)] { return [
    ("testInitializationSetsClientAddressOnRequest", testInitializationSetsClientAddressOnRequest),
    ("testInitializationSetsMethod", testInitializationSetsMethod),
    ("testInitializationSetsPath", testInitializationSetsPath),
    ("testInitializationSetsDomain", testInitializationSetsDomain),
    ("testInitializationSetsHttpVersion", testInitializationSetsHttpVersion),
    ("testInitializationRemovesQueryStringFromPath", testInitializationRemovesQueryStringFromPath),
    ("testInitializationSetsRequestParameters", testInitializationSetsRequestParameters),
    ("testParseRequestParametersGetsParametersFromQueryString", testParseRequestParametersGetsParametersFromQueryString),
    ("testParseRequestParametersCanParseMultipleValuesForParameter", testParseRequestParametersCanParseMultipleValuesForParameter),
    ("testParseRequestParametersGetsParametersFromPostRequest", testParseRequestParametersGetsParametersFromPostRequest),
    ("testParseRequestParametersGetsParametersFromPostRequestWithCharsetInContentType", testParseRequestParametersGetsParametersFromPostRequestWithCharsetInContentType),
    ("testParseRequestParametersGetsParametersFromMultipartForm", testParseRequestParametersGetsParametersFromMultipartForm),
    ("testParseRequestWithMultipartFormWithBoundariesGetsEmptyParameters", testParseRequestWithMultipartFormWithBoundariesGetsEmptyParameters),
    ("testParseRequestParametersGetsFileFromMultipartForm", testParseRequestParametersGetsFileFromMultipartForm),
    ("testSendRequestCanSendRequestAsynchronously", testSendRequestCanSendRequestAsynchronously),
    ("testSendRequestCanSendRequestSynchronously", testSendRequestCanSendRequestSynchronously),
    ("testParameterDictionarySubscriptWithStringArrayGetsValue", testParameterDictionarySubscriptWithStringArrayGetsValue),
    ("testParameterDictionarySubscriptWithStringArrayWithMissingValueGetsEmptyArray",testParameterDictionarySubscriptWithStringArrayWithMissingValueGetsEmptyArray),
    ("testParameterDictionarySubscriptWithStringArrayCanSetValue", testParameterDictionarySubscriptWithStringArrayCanSetValue),
    ("testParameterDictionarySubscriptWithStringGetsValue", testParameterDictionarySubscriptWithStringGetsValue),
    ("testParameterDictionarySubscriptWithStringWithMissingValueGetsEmptyString", testParameterDictionarySubscriptWithStringWithMissingValueGetsEmptyString),
    ("testParameterDictionarySubscriptWithStringWithMultipleValuesGetsFirstValue", testParameterDictionarySubscriptWithStringWithMultipleValuesGetsFirstValue),
    ("testParameterDictionarySubscriptWithStringCanSetValue", testParameterDictionarySubscriptWithStringCanSetValue),
    ("testParameterDictionarySubscriptWithNullableStringGetsValue", testParameterDictionarySubscriptWithNullableStringGetsValue),
    ("testParameterDictionarySubscriptWithNullableStringWithMissingValueIsNil", testParameterDictionarySubscriptWithNullableStringWithMissingValueIsNil),
    ("testParameterDictionarySubscriptWithNullableStringWithMultipleValuesIsFirstValue", testParameterDictionarySubscriptWithNullableStringWithMultipleValuesIsFirstValue),
    ("testParameterDictionarySubscriptWithNullableStringCanSetValue", testParameterDictionarySubscriptWithNullableStringCanSetValue),
    ("testParameterDictionarySubscriptCanTriggerGuardStatements", testParameterDictionarySubscriptCanTriggerGuardStatements),
    ("testParameterDictionarySubscriptWithIntegerGetsValue", testParameterDictionarySubscriptWithIntegerGetsValue),
    ("testParameterDictionarySubscriptWithIntegerWithMissingValueGetsZero", testParameterDictionarySubscriptWithIntegerWithMissingValueGetsZero),
    ("testParameterDictionarySubscriptWithIntegerWithNonIntegerValueGetsZero", testParameterDictionarySubscriptWithIntegerWithNonIntegerValueGetsZero),
    ("testParameterDictionarySubscriptWithNullableIntegerGetsValue", testParameterDictionarySubscriptWithNullableIntegerGetsValue),
    ("testParameterDictionarySubscriptWithNullableIntegerWithMissingValueGetsNil", testParameterDictionarySubscriptWithNullableIntegerWithMissingValueGetsNil),
    ("testParameterDictionarySubscriptWithNullableIntegerWithNonIntegerValueGetsZero", testParameterDictionarySubscriptWithNullableIntegerWithNonIntegerValueGetsZero),
    ("testParameterDictionarySubscriptWithIntegerCanSetValue", testParameterDictionarySubscriptWithIntegerCanSetValue),
    ("testParameterDictionaryCanAppendValueToList", testParameterDictionaryCanAppendValueToList),
    ("testParameterDictionarySubscriptWithNullableIntegerCanSetValue", testParameterDictionarySubscriptWithNullableIntegerCanSetValue),
    ("testExtractWithPatternGetsPiecesOfLine", testExtractWithPatternGetsPiecesOfLine),
    ("testExtractWithPatternGetsEmptyListForNoMatch", testExtractWithPatternGetsEmptyListForNoMatch),
    ("testExtractWithPatternWithInvalidPatternReturnsEmptyArray", testExtractWithPatternWithInvalidPatternReturnsEmptyArray),
    ("testDecodeQueryStringGetsParameters", testDecodeQueryStringGetsParameters),
    ("testDecodeQueryStringGetsEmptyStringWithoutEqualSign", testDecodeQueryStringGetsEmptyStringWithoutEqualSign),
    //("testDecodeQueryStringLeavesBadEscapeValueUnescaped", testDecodeQueryStringLeavesBadEscapeValueUnescaped),
    ("testDecodeQueryStringCanGetMultipleValuesForParameter", testDecodeQueryStringCanGetMultipleValuesForParameter),
    ("testParseTimeCanParseRfc822Format", testParseTimeCanParseRfc822Format),
    ("testParseTimeCanParseRfc850Format", testParseTimeCanParseRfc850Format),
    ("testParseTimeCanParsePosixFormat", testParseTimeCanParsePosixFormat),
    ("testInitializerCanInitializeRequestInfo", testInitializerCanInitializeRequestInfo),
    ("testInitializerSanitizesReservedCharactersInParameters", testInitializerSanitizesReservedCharactersInParameters),
    ("testInitializerWithGetRequestPutsQueryStringInPath", testInitializerWithGetRequestPutsQueryStringInPath),
    ("testInitializerCanInitializeSessionInfo", testInitializerCanInitializeSessionInfo),
    ("testInitializerCanInitializeCookieInfo", testInitializerCanInitializeCookieInfo),
    //("testInitializeWithNonUtf8ParameterTranslatesToEmptyString", testInitializeWithNonUtf8ParameterTranslatesToEmptyString),
    ("testRequestsAreEqualWithSameData", testRequestsAreEqualWithSameData),
    ("testRequestsAreUnequalWithDifferentData", testRequestsAreUnequalWithDifferentData),
    ("testParameterDictionariesAreEqualWithSameDictionaries", testParameterDictionariesAreEqualWithSameDictionaries),
    ("testParameterDictionariesAreUnequalWithDifferentDictionaries", testParameterDictionariesAreUnequalWithDifferentDictionaries),
    ("testContentPreferenceOptionFromHeaderWithSimpleOptionSetsTypeAndQuality", testContentPreferenceOptionFromHeaderWithSimpleOptionSetsTypeAndQuality),
    ("testContentPreferenceOptionFromHeaderWithQualitySetsQuality", testContentPreferenceOptionFromHeaderWithQualitySetsQuality),
    ("testContentPreferenceOptionFromHeaderWithBadQualityFieldSetsQualityToZero", testContentPreferenceOptionFromHeaderWithBadQualityFieldSetsQualityToZero),
    ("testContentPreferenceOptionFromHeaderWithFlagsSetsFlags", testContentPreferenceOptionFromHeaderWithFlagsSetsFlags),
    ("testContentPreferenceOptionWithSubtypeSetsSubtype", testContentPreferenceOptionWithSubtypeSetsSubtype),
    ("testContentPreferenceOptionFromHeaderTrimsSpaces", testContentPreferenceOptionFromHeaderTrimsSpaces),
    ("testContentPreferenceOptionMatchesCompleteMatch", testContentPreferenceOptionMatchesCompleteMatch),
    ("testContentPreferenceOptionDoesNotMatchDifferentSubtype", testContentPreferenceOptionDoesNotMatchDifferentSubtype),
    ("testContentPreferenceOptionMatchLevelWithWildcardSubtypeIsMatch", testContentPreferenceOptionMatchLevelWithWildcardSubtypeIsMatch),
    ("testContentPreferenceOptionMatchLevelWithFullWildcardIsMatch", testContentPreferenceOptionMatchLevelWithFullWildcardIsMatch),
    ("testContentPreferenceOptionWithNoSubtypeWithMatchIsMatch", testContentPreferenceOptionWithNoSubtypeWithMatchIsMatch),
    ("testContentPreferenceOptionWithNoSubtypeWithWildcardIsMatch", testContentPreferenceOptionWithNoSubtypeWithWildcardIsMatch),
    ("testContentPreferenceOptionWithNoSubtypeWithMismatchIsNotMatch", testContentPreferenceOptionWithNoSubtypeWithMismatchIsNotMatch),
    ("testContentPreferenceOptionWithAllFlagsMatchingIsMatch", testContentPreferenceOptionWithAllFlagsMatchingIsMatch),
    ("testContentPreferenceOptionWithFlagsMissingIsNotMatch", testContentPreferenceOptionWithFlagsMissingIsNotMatch),
    ("testContentPreferenceOptionWithWrongFlagValueIsNotMatch", testContentPreferenceOptionWithWrongFlagValueIsNotMatch),
    ("testContentPreferenceOptionWithExtraFlagValueIsMatch", testContentPreferenceOptionWithExtraFlagValueIsMatch),
    ("testContentPreferenceOptionWithSameInformationAreEqual", testContentPreferenceOptionWithSameInformationAreEqual),
    ("testContentPreferenceOptionWithDifferentTypesAreNotEqual", testContentPreferenceOptionWithDifferentTypesAreNotEqual),
    ("testContentPreferenceOptionWithDifferentSubtypesAreNotEqual", testContentPreferenceOptionWithDifferentSubtypesAreNotEqual),
    ("testContentPreferenceOptionWithDifferentFlagsAreNotEqual", testContentPreferenceOptionWithDifferentFlagsAreNotEqual),
    ("testContentPreferenceOptionWithDifferentQualitiesAreNotEqual", testContentPreferenceOptionWithDifferentQualitiesAreNotEqual),
    ("testContentPreferenceFromHeaderParsesOptions", testContentPreferenceFromHeaderParsesOptions),
    ("testContentPreferenceFromHeaderPutsHighQualityOptionsBeforeLowQualityOptions", testContentPreferenceFromHeaderPutsHighQualityOptionsBeforeLowQualityOptions),
    ("testContentPreferenceBestMatchWithOneValueWithAcceptableValueReturnsValue", testContentPreferenceBestMatchWithOneValueWithAcceptableValueReturnsValue),
    ("testContentPreferenceBestMatchWithMultipleValuesReturnsValueWithHighestMatch", testContentPreferenceBestMatchWithMultipleValuesReturnsValueWithHighestMatch),
    ("testContentPreferenceBestMatchWithNoMatchReturnsNil", testContentPreferenceBestMatchWithNoMatchReturnsNil),
    ("testContentPreferencesWithSameOptionsAreEqual", testContentPreferencesWithSameOptionsAreEqual),
    ("testContentPreferencesWithDifferentOptionsAreNotEqual", testContentPreferencesWithDifferentOptionsAreNotEqual),
  ]}

  func setUp() {
    setUpTestCase()
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }
    requestString = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header value\r\nHost: tailorframe.work\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
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

  func testInitializationSetsDomain() {
    assert(request.domain, equals: "tailorframe.work")
    requestString = "GET /test/path HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
    assert(request.domain, equals: "", message: "sets domain to an empty string without the Host headers")
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
  
  func testInitializationSetsRequestParameters() {
    requestString = requestString.stringByReplacingOccurrencesOfString("/test/path", withString: "/test/path?count=5")
    assert(request.params["count"], equals: "5", message: "sets request parameter to correct value")
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
    requestString = "GET /test/path?count=5&id=6 HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
    assert(request.params["count"], equals: "5", message: "sets count parameter")
    assert(request.params["id"], equals: "6", message: "sets id parameter")
  }
  
  func testParseRequestParametersCanParseMultipleValuesForParameter() {
    requestString = "GET /test/path?count=5&ids[]=6&ids[]=7 HTTP/1.1\r\nX-Custom-Field: header value\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\nRequest Body"
    assert(request.params["count"], equals: "5", message: "sets count parameter")
    assert(request.params["ids[]"], equals: ["6","7"], message: "sets id parameters")
  }
  
  func testParseRequestParametersGetsParametersFromPostRequest() {
    requestString = "POST /test/path HTTP/1.1\r\nContent-Type: application/x-www-form-urlencoded\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\ncount=5&id=6"
    assert(request.params["count"], equals: "5", message: "sets count parameter")
    assert(request.params["id"], equals: "6", message: "sets id parameter")
  }
  
  func testParseRequestParametersGetsParametersFromPostRequestWithCharsetInContentType() {
    requestString = "POST /test/path HTTP/1.1\r\nContent-Type: application/x-www-form-urlencoded charset=\"UTF8\"\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\ncount=5&id=6"
    assert(request.params["count"], equals: "5", message: "sets count parameter")
    assert(request.params["id"], equals: "6", message: "sets id parameter")
  }
  
  func testParseRequestParametersGetsParametersFromMultipartForm() {
    let boundary = "----TestFormBoundaryK7Slx2O95dkvjQ14"
    requestString = "POST /test/path HTTP/1.1\r\nContent-Type: multipart/form-data; boundary=\(boundary)\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param2\"\r\n\r\nvalue2\r\n--\(boundary)--"
    let params = request.params

    assert(params["param1"], equals: "value1", message: "sets param1")
    assert(params["param2"], equals: "value2", message: "sets param2")
  }
  
  func testParseRequestWithMultipartFormWithBoundariesGetsEmptyParameters() {
    let boundary = "----TestFormBoundaryK7Slx2O95dkvjQ14"
    requestString = "POST /test/path HTTP/1.1\r\nContent-Type: multipart/form-data\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param2\"\r\n\r\nvalue2\r\n--\(boundary)--"
    assert(request.params.raw.isEmpty)
  }
  
  func testParseRequestParametersGetsFileFromMultipartForm() {
    let boundary = "----TestFormBoundaryK7Slx2O95dkvjQ14"
    requestString = "POST /test/path HTTP/1.1\r\nContent-Type: multipart/form-data; boundary=\(boundary)\r\nReferer: searchtheweb.com\r\nCookie: key1=value1; key2=value2\r\nCookie: key3=value3\r\n\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param1\"\r\n\r\nvalue1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"param2\"; filename=\"record.log\"\r\nContent-Type: text/plain\r\n\r\nthis is a log\r\n--\(boundary)--"
    assert(request.params["param1"], equals: "value1", message: "sets param1")
    
    if let file = request.uploadedFiles["param2"] {
      assert(file["contentType"] as? String, equals: "text/plain", message: "sets content type")
      
      let data = NSData(bytes: "this is a log".utf8)
      assert(file["data"] as? NSData, equals: data, message: "sets data")
    }
    else {
      XCTFail("sets param2")
    }
  }

  func testSendRequestCanSendRequestAsynchronously() {
    let request = Request(domain: "tailorframe.work", path: "/", secure: false, headers: ["Accept-Charset": "utf-8"])
    let expectation = expectationWithDescription("callback called")
    request.send {
      response in
      expectation.fulfill()
      self.assert(response.responseCode.code, equals: 301)
      self.assert(response.headers["Location"], equals: "https://tailorframe.work/")
      self.assert(response.bodyText, contains: "301 Moved Permanently")
    }
    waitForExpectationsWithTimeout(5, handler: nil)
  }

  func testSendRequestCanSendRequestSynchronously() {
    let request = Request(domain: "tailorframe.work", path: "/", secure: false, headers: ["Accept-Charset": "utf-8"])
    var response = request.send()
    self.assert(response.responseCode.code, equals: 301)
    self.assert(response.headers["Location"], equals: "https://tailorframe.work/")
    self.assert(response.bodyText, contains: "301 Moved Permanently")
  }
  
  @available(*, deprecated) func testRequestParametersGetsParametersFromDictionary() {
    var request = Request()
    request.params = Request.ParameterDictionary(["foo": "bar", "baz": "bat"])
    assert(request.requestParameters, equals: ["foo": "bar", "baz": "bat"])
  }
  
  @available(*, deprecated) func testRequestParametersSetsParametersInDictionary() {
    var request = Request()
    request.params = Request.ParameterDictionary(["foo": "bar", "baz": "bat"])
    request.requestParameters["a"] = "b"
    assert(request.requestParameters, equals: ["foo": "bar", "baz": "bat", "a": "b"])
  }
  
  func testParameterDictionarySubscriptWithStringArrayGetsValue() {
    let params = Request.ParameterDictionary(["foo": ["bar", "baz"]])
    let value = params["foo"] as [String]
    assert(value, equals: ["bar", "baz"])
  }
  
  func testParameterDictionarySubscriptWithStringArrayWithMissingValueGetsEmptyArray() {
    let params = Request.ParameterDictionary(["foo": ["bar", "baz"]])
    let value = params["baz"] as [String]
    assert(value, equals: [])
  }
  
  func testParameterDictionarySubscriptWithStringArrayCanSetValue() {
    var params = Request.ParameterDictionary(["foo": ["bar", "baz"]])
    params["foo"] = ["a","b"]
    assert(params.raw["foo"] ?? [], equals: ["a", "b"])
  }
  
  func testParameterDictionarySubscriptWithStringGetsValue() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    let value = params["foo"] as String
    assert(value, equals: "bar")
  }
  
  func testParameterDictionarySubscriptWithStringWithMissingValueGetsEmptyString() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    let value = params["baz"] as String
    assert(value, equals: "")
  }
  
  func testParameterDictionarySubscriptWithStringWithMultipleValuesGetsFirstValue() {
    let params = Request.ParameterDictionary(["foo": ["bar", "baz"]])
    let value = params["foo"] as String
    assert(value, equals: "bar")
  }
  
  func testParameterDictionarySubscriptWithStringCanSetValue() {
    var params = Request.ParameterDictionary(["foo": ["bar", "baz"]])
    params["foo"] = "a"
    assert(params.raw["foo"] ?? [], equals: ["a"])
  }
  
  func testParameterDictionarySubscriptWithNullableStringGetsValue() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    let value = params["foo"] as String?
    assert(value, equals: "bar")
  }
  
  func testParameterDictionarySubscriptWithNullableStringWithMissingValueIsNil() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    let value = params["baz"] as String?
    assert(isNil: value)
    assert(params["baz"] ?? "bat", equals: "bat")
  }
  
  func testParameterDictionarySubscriptWithNullableStringWithMultipleValuesIsFirstValue() {
    let params = Request.ParameterDictionary(["foo": ["baz", "bat"]])
    let value = params["foo"] as String?
    assert(value, equals: "baz")
  }
  
  func testParameterDictionarySubscriptWithNullableStringCanSetValue() {
    var params = Request.ParameterDictionary(["foo": ["bar", "baz"]])
    let value: String? = "a"
    params["foo"] = value
    assert(params.raw["foo"] ?? [], equals: ["a"])
    params["foo"] = nil as String?
    assert(params.raw["foo"] ?? [], equals: [])
  }
  
  func testParameterDictionarySubscriptCanTriggerGuardStatements() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    guard let value = params["foo"] as String? else {
      assert(false, message: "got nil in a guard statement for a present value")
      return
    }
    assert(value, equals: "bar")
    guard let _ = params["baz"] as String? else {
      assert(true, message: "got nil in a guard statement for a missing value")
      return
    }
  }
  
  func testParameterDictionarySubscriptWithIntegerGetsValue() {
    let params = Request.ParameterDictionary(["foo": "27"])
    let value = params["foo"] as Int
    assert(value, equals: 27)
  }
  
  func testParameterDictionarySubscriptWithIntegerWithMissingValueGetsZero() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    let value = params["baz"] as Int
    assert(value, equals: 0)
  }
  
  func testParameterDictionarySubscriptWithIntegerWithNonIntegerValueGetsZero() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    let value = params["foo"] as Int
    assert(value, equals: 0)
  }
  
  func testParameterDictionarySubscriptWithNullableIntegerGetsValue() {
    let params = Request.ParameterDictionary(["foo": "27"])
    let value = params["foo"] as Int?
    assert(value, equals: 27)
  }
  
  func testParameterDictionarySubscriptWithNullableIntegerWithMissingValueGetsNil() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    let value: Int? = params["baz"]
    assert(isNil: value)
  }
  
  func testParameterDictionarySubscriptWithNullableIntegerWithNonIntegerValueGetsZero() {
    let params = Request.ParameterDictionary(["foo": "bar"])
    let value: Int? = params["foo"]
    assert(isNil: value)
  }
  
  func testParameterDictionarySubscriptWithIntegerCanSetValue() {
    var params = Request.ParameterDictionary(["foo": "bar"])
    params["foo"] = 25
    assert(params.raw["foo"] ?? [], equals: ["25"])
  }
  
  func testParameterDictionaryCanAppendValueToList() {
    var params = Request.ParameterDictionary(["foo": "bar"])
    params.append(value: "baz", forKey: "foo")
    assert(params.raw["foo"] ?? [], equals: ["bar", "baz"])
  }
  
  func testParameterDictionarySubscriptWithNullableIntegerCanSetValue() {
    var params = Request.ParameterDictionary(["foo": ["bar", "baz"]])
    let value: Int? = 5
    params["foo"] = value
    assert(params.raw["foo"] ?? [], equals: ["5"])
    params["foo"] = nil as Int?
    assert(params.raw["foo"] ?? [], equals: [])
  }

  //MARK: - Helper Methods
  
  func testExtractWithPatternGetsPiecesOfLine() {
    let matches = Request.extractWithPattern("Content-Type: text/plain", pattern: "^([\\w-]*): (.*)$")
    assert(matches.count, equals: 2, message: "gets two matches")
    if matches.count < 2 { return }
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
    assert(decoded["key1"] ?? [], equals: ["value1"], message: "gets simple param")
    assert(decoded["key2"] ?? [], equals: ["value=a b"], message: "decodes param with escapes")
  }
  
  func testDecodeQueryStringGetsEmptyStringWithoutEqualSign() {
    let queryString = "key1&key2"
    let decoded = Request.decodeQueryString(queryString)
    
    assert(decoded["key1"] ?? [], equals: [""], message: "gets key1")
    assert(decoded["key2"] ?? [], equals: [""], message: "gets key2")
  }
  
  func testDecodeQueryStringLeavesBadEscapeValueUnescaped() {
    let queryString = "key1=1&key%1=2"
    let decoded = Request.decodeQueryString(queryString)
    assert(Array(decoded.keys), equals: ["key1", "key%1"])
  }
  
  func testDecodeQueryStringCanGetMultipleValuesForParameter() {
    let queryString = "key1=value1&key1=value2"
    let decoded = Request.decodeQueryString(queryString)
    
    assert(decoded.keys.count, equals: 1)
    assert(decoded["key1"] ?? [], equals: ["value1", "value2"], message: "gets simple param")
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
    let request = Request(clientAddress: "127.0.0.1", method: "POST", parameters: params, domain: "mysite.com", path: "/home", secure: false)
    assert(request.domain, equals: "mysite.com")
    assert(request.fullPath, equals: "/home")
    assert(!request.secure)
    assert(request.bodyText, equals: "key1=value1&key2=value2_value3")
    assert(request.params, equals: Request.ParameterDictionary(params), message: "sets request parameters")
    assert(request.method, equals: "POST", message: "sets method")
    assert(request.clientAddress, equals: "127.0.0.1", message: "sets client address")
  }
  
  func testInitializerSanitizesReservedCharactersInParameters() {
    let params = ["key1": "value1", "key2/key3": "value2&value3"]
    let request = Request(clientAddress: "127.0.0.1", method: "POST", parameters: params, path: "/home")
    assert(request.fullPath, equals: "/home")
    assert(request.bodyText, equals: "key1=value1&key2%2Fkey3=value2%26value3")
    assert(request.params, equals: Request.ParameterDictionary(params), message: "sets request parameters")
    assert(request.method, equals: "POST", message: "sets method")
    assert(request.clientAddress, equals: "127.0.0.1", message: "sets client address")
  }
  
  func testInitializerWithGetRequestPutsQueryStringInPath() {
    let params = ["key1": "value1", "key2/key3": "value2&value3"]
    let request = Request(clientAddress: "127.0.0.1", method: "GET", parameters: params, path: "/home")
    assert(request.path, equals: "/home", message: "does not include the query string in the short path")
    assert(request.fullPath, equals: "/home?key1=value1&key2%2Fkey3=value2%26value3", message: "includes the query string in the full path")
    assert(request.bodyText, equals: "", message: "leaves the body blank")
    assert(request.params, equals: Request.ParameterDictionary(params), message: "sets request parameters")
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
    let badString = NSString(data: data, encoding: NSUTF16BigEndianStringEncoding)!.bridge()
    let request = Request(parameters: ["key": badString])
    assert(request.params.raw["key"] ?? [], equals: [""])
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
  
  func testParameterDictionariesAreEqualWithSameDictionaries() {
    let dictionary1 = Request.ParameterDictionary(["a": ["b"], "c": ["d", "e"]])
    let dictionary2 = Request.ParameterDictionary(["a": ["b"], "c": ["d", "e"]])
    assert(dictionary1, equals: dictionary2)
  }
  
  func testParameterDictionariesAreUnequalWithDifferentDictionaries() {
    let dictionary1 = Request.ParameterDictionary(["a": ["b"], "c": ["d"]])
    let dictionary2 = Request.ParameterDictionary(["a": "b", "c": "e"])
    let dictionary3 = Request.ParameterDictionary(["a": "b", "e": "d"])
    let dictionary4 = Request.ParameterDictionary(["a": ["b"], "c": ["d", "e"]])
    assert(dictionary1, doesNotEqual: dictionary2)
    assert(dictionary1, doesNotEqual: dictionary3)
    assert(dictionary1, doesNotEqual: dictionary4)
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
  
  func testContentPreferencesWithDifferentOptionsAreNotEqual() {
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
