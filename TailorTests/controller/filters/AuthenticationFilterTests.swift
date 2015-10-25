import Tailor
import TailorTesting
import XCTest

class AuthenticationFilterTests: XCTestCase, TailorTestable {
  let filter = AuthenticationFilter("/sessions/new")
  
  override func setUp() {
    super.setUp()
    setUpTestCase()
    Application.configuration.userType = TestUser.self
    TestUser().save()
  }
  
  func testFetchUserWithValidUserIdReturnsUser() {
    let request = Request(sessionData: ["userId": "1"])
    let response = Response()
    let user = try? filter.fetchUser(request, response: response) as TestUser
    assert(user?.id, equals: 1)
  }
  
  func testFetchUserWithInvalidUserIdRedirectsToSignInUrl() {
    let request = Request(sessionData: ["userId": "2"])
    let response = Response()
    do {
      try filter.fetchUser(request, response: response) as TestUser
      assert(false, message: "should throw an exception")
    }
    catch let ControllerError.UnprocessableRequest(response) {
      assert(response.responseCode, equals: .SeeOther)
      assert(response.headers["Location"], equals: filter.signInUrl)
    }
    catch {
      assert(false, message: "threw unexpected error")
    }
  }
  
  func testFetchUserWithNoUserIdRedirectsToSignInUrl() {
    let request = Request()
    let response = Response()
    do {
      try filter.fetchUser(request, response: response) as TestUser
      assert(false, message: "should throw an exception")
    }
    catch let ControllerError.UnprocessableRequest(response) {
      assert(response.responseCode, equals: .SeeOther)
      assert(response.headers["Location"], equals: filter.signInUrl)
    }
    catch {
      assert(false, message: "threw unexpected error")
    }
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
    let request = Request(sessionData: ["userId": "2"], path: "/test/path")
    let response = Response()
    let expectation = expectationWithDescription("callback called")
    filter.preProcess(request, response: response) {
      request, response, stop in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .SeeOther)
      self.assert(response.headers["Location"], equals: "/sessions/new")
      self.assert(response.bodyString, equals: "<html><body>You are being <a href=\"/sessions/new\">redirected</a>.")
      self.assert(response.session["_redirectPath"], equals: "/test/path", message: "puts the original path in the session")
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