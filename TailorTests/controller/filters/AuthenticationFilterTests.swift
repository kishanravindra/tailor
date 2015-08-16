import Tailor
import TailorTesting

class AuthenticationFilterTests: TailorTestCase {
  let filter = AuthenticationFilter("/sessions/new")
  
  override func setUp() {
    super.setUp()
    Application.configuration.userType = TestUser.self
    TestUser().save()
  }
  
  func testPreProcessWithValidUserIdDoesNotChangeResponse() {
    let request = Request(sessionData: ["userId": "1"])
    let response = Response()
    let expectation = expectationWithDescription("callback called")
    filter.preProcess(request, response: response) {
      request, response, stop in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .Ok)
      self.assert(!stop)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithInvalidUserIdRedirectsToSignInUrl() {
    let request = Request(sessionData: ["userId": "2"])
    let response = Response()
    let expectation = expectationWithDescription("callback called")
    filter.preProcess(request, response: response) {
      request, response, stop in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther)
      self.assert(response.headers["Location"], equals: "/sessions/new")
      self.assert(response.bodyString, equals: "<html><body>You are being <a href=\"/sessions/new\">redirected</a>.")
      self.assert(stop)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithNoUserIdRedirectsToSignInUrl() {
    let request = Request()
    let response = Response()
    let expectation = expectationWithDescription("callback called")
    filter.preProcess(request, response: response) {
      request, response, stop in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther)
      self.assert(response.headers["Location"], equals: "/sessions/new")
      self.assert(response.bodyString, equals: "<html><body>You are being <a href=\"/sessions/new\">redirected</a>.")
      self.assert(stop)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithNoUserTypeRedirectsToSignInUrl() {
    let request = Request()
    let response = Response()
    Application.configuration.userType = nil
    let expectation = expectationWithDescription("callback called")
    filter.preProcess(request, response: response) {
      request, response, stop in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther)
      self.assert(response.headers["Location"], equals: "/sessions/new")
      self.assert(response.bodyString, equals: "<html><body>You are being <a href=\"/sessions/new\">redirected</a>.")
      self.assert(stop)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPostProcessDoesNotChangeResponse() {
    let request = Request()
    var response = Response()
    response.appendString("Hello")
    let expectation = expectationWithDescription("callback called")
    filter.postProcess(request, response: response) {
      response in
      expectation.fulfill()
      self.assert(response.bodyString, equals: "Hello")
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testFiltersWithSameUrlAreEqual() {
    let filter1 = AuthenticationFilter("/test/path")
    let filter2 = AuthenticationFilter("/test/path")
    assert(filter1, equals: filter2)
  }
  
  func testFiltersWithDifferentUrlsAreNotEqual() {
    let filter1 = AuthenticationFilter("/test/path1")
    let filter2 = AuthenticationFilter("/test/path2")
    assert(filter1, doesNotEqual: filter2)
  }
}