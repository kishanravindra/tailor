import Tailor
import TailorTesting

class EtagFilterTests: TailorTestCase {
  let bodyText = "Hello"
  let tag = NSData(bytes: "Hello".utf8).md5Hash
  
  func testPreProcessDoesNotModifyResponse() {
    let filter = EtagFilter()
    let request = Request()
    var response = Response()
    response.appendString("hello")
    let expectation = expectationWithDescription("callback called")
    filter.preProcess(request, response: response) {
      response, stop in
      expectation.fulfill()
      self.assert(response.bodyString, equals: "hello")
      self.assert(!stop)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPostProcessWithNoEtagSendsResponseUnmodified() {
    let filter = EtagFilter()
    let request = Request()
    var response = Response()
    response.responseCode = .Ok
    response.appendString(bodyText)
    let expectation = expectationWithDescription("callback called")
    filter.postProcess(request, response: response) {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .Ok)
      self.assert(response.headers["ETag"], equals: self.tag)
      self.assert(response.bodyString, equals: self.bodyText)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPostProcessWithIncorrectEtagSendsResponseWithEtag() {
    let filter = EtagFilter()
    let request = Request(headers: ["If-None-Match": "asdfasd"])
    var response = Response()
    response.responseCode = .Ok
    response.appendString(bodyText)
    let expectation = expectationWithDescription("callback called")
    filter.postProcess(request, response: response) {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .Ok)
      self.assert(response.headers["ETag"], equals: self.tag)
      self.assert(response.bodyString, equals: self.bodyText)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPostProcessWithMatchingEtagSendsNotModifiedResponse() {
    let filter = EtagFilter()
    let request = Request(headers: ["If-None-Match": tag])
    var response = Response()
    response.responseCode = .Ok
    response.appendString(bodyText)
    let expectation = expectationWithDescription("callback called")
    filter.postProcess(request, response: response) {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .NotModified)
      self.assert(response.headers["ETag"], equals: self.tag)
      self.assert(response.body.length, equals: 0)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPostProcessWithNon200RequestDoesNotSetEtag() {
    let filter = EtagFilter()
    let request = Request()
    var response = Response()
    response.responseCode = .Created
    response.appendString(bodyText)
    let expectation = expectationWithDescription("callback called")
    filter.postProcess(request, response: response) {
      response in
      expectation.fulfill()
      self.assert(response.responseCode, equals: .Created)
      self.assert(isNil: response.headers["ETag"])
      self.assert(response.bodyString, equals: self.bodyText)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testEtagFiltersAreEqual() {
    let filter1 = EtagFilter()
    let filter2 = EtagFilter()
    assert(filter1, equals: filter2)
  }
}
