import Tailor
import TailorTesting

class CsrfFilterTests: TailorTestCase {
  let filter = CsrfFilter()
  
  func testPreProcessWithNoCsrfKeyPutsOneInSession() {
    let expectation = expectationWithDescription("callback called")
    
    filter.preProcess(Request(), response: Response()) {
      request, response, stop in
      let key = request.session["csrfKey"]
      expectation.fulfill()
      self.assert(isNotNil: key)
      self.assert(key?.characters.count, equals: 64)
    }
    
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithCsrfKeyLeavesItInSession() {
    let expectation = expectationWithDescription("callback called")
    
    filter.preProcess(Request(sessionData: ["csrfKey": "abcd"]), response: Response()) {
      request, response, stop in
      let key = request.session["csrfKey"]
      expectation.fulfill()
      self.assert(key, equals: "abcd")
    }
    
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithNoCsrfKeyInParametersWithGetRequestAllowsRequestToContinue() {
    let expectation = expectationWithDescription("callback called")
    
    filter.preProcess(Request(sessionData: ["csrfKey": "abcd"]), response: Response()) {
      request, response, stop in
      expectation.fulfill()
      self.assert(!stop)
    }
    
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithNoCsrfKeyInParametersWithPostRequestHaltsRequest() {
    let expectation = expectationWithDescription("callback called")
    
    filter.preProcess(Request(method: "POST", sessionData: ["csrfKey": "abcd"]), response: Response()) {
      request, response, stop in
      expectation.fulfill()
      self.assert(stop)
      self.assert(response.responseCode, equals: .Forbidden)
    }
    
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithIncorrectCsrfKeyInParametersWithPostRequestHaltsRequest() {
    let expectation = expectationWithDescription("callback called")
    
    filter.preProcess(Request(method: "POST", parameters: ["_csrfKey": "abcde"], sessionData: ["csrfKey": "abcd"]), response: Response()) {
      request, response, stop in
      expectation.fulfill()
      self.assert(stop)
      self.assert(response.responseCode, equals: .Forbidden)
    }
    
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithCorrectCsrfKeyInParametersWithPostRequestContinuesWithRequest() {
    let expectation = expectationWithDescription("callback called")
    
    filter.preProcess(Request(method: "POST", parameters: ["_csrfKey": "abcd"], sessionData: ["csrfKey": "abcd"]), response: Response()) {
      request, response, stop in
      expectation.fulfill()
      self.assert(!stop)
      self.assert(response.responseCode, equals: .Ok)
    }
    
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPostProcessDoesNotModifyResponse() {
    let request = Request()
    var response = Response()
    response.appendString("Hi")
    filter.postProcess(request, response: response) {
      newResponse in
      self.assert(newResponse.body, equals: response.body)
    }
  }
  
  func testCsrfFiltersAreEqual() {
    let filter2 = CsrfFilter()
    assert(filter, equals: filter2)
  }
}