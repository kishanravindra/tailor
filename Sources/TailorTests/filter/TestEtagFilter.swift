import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestEtagFilter: XCTestCase, TailorTestable {
  let bodyText = "Hello"
  let tag = NSData(bytes: "Hello".utf8).md5Hash
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testPreProcessDoesNotModifyResponse", testPreProcessDoesNotModifyResponse),
    ("testPostProcessWithNoEtagSendsResponseUnmodified", testPostProcessWithNoEtagSendsResponseUnmodified),
    ("testPostProcessWithIncorrectEtagSendsResponseWithEtag", testPostProcessWithIncorrectEtagSendsResponseWithEtag),
    ("testPostProcessWithMatchingEtagSendsNotModifiedResponse", testPostProcessWithMatchingEtagSendsNotModifiedResponse),
    ("testPostProcessWithNon200RequestDoesNotSetEtag", testPostProcessWithNon200RequestDoesNotSetEtag),
    ("testEtagFiltersAreEqual", testEtagFiltersAreEqual),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func testPreProcessDoesNotModifyResponse() {
    let filter = EtagFilter()
    let request = Request()
    var response = Response()
    response.appendString("hello")
    let expectation = expectationWithDescription("callback called")
    filter.preProcess(request, response: response) {
      request, response, stop in
      expectation.fulfill()
      self.assert(response.bodyText, equals: "hello")
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
      self.assert(response.bodyText, equals: self.bodyText)
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
      self.assert(response.bodyText, equals: self.bodyText)
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
      self.assert(response.bodyData.length, equals: 0)
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
      self.assert(response.bodyText, equals: self.bodyText)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testEtagFiltersAreEqual() {
    let filter1 = EtagFilter()
    let filter2 = EtagFilter()
    assert(filter1, equals: filter2)
  }
}
