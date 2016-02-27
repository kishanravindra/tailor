@testable import Tailor
import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestRequestFilterType : XCTestCase, TailorTestable {
  struct TestFilter: RequestFilterType {
    func preProcess(request: Request, response: Response, callback: (Request, Response, stop: Bool)->Void) {
      
    }
    func postProcess(request: Request, response: Response, callback: Connection.ResponseCallback) {
      
    }
  }

  //FIXME: Re-enable disabled tests
  var allTests: [(String, () throws -> Void)] { return [
    ("testPreProcessWithBlockWithNoErrorContinuesProcessing", testPreProcessWithBlockWithNoErrorContinuesProcessing),
    ("testPreProcessWithBlockWithControllerErrorHaltsProcessing", testPreProcessWithBlockWithControllerErrorHaltsProcessing),
    //("testPreProcessWithBlockWithNsErrorContinuesProcessing", testPreProcessWithBlockWithNsErrorContinuesProcessing),
  ]}
  
  func setUp() {
    setUpTestCase()
  }
  
  func testPreProcessWithBlockWithNoErrorContinuesProcessing() {
    let expectation = expectationWithDescription("callback called")
    let request = Request(path: "/test/path")
    var response = Response()
    response.appendString("Test")
    
    let callback = {
      (request: Request, response: Response, stop: Bool) in
      expectation.fulfill()
      self.assert(!stop, message: "Allows processing to continue")
      self.assert(request.path, equals: "/test/path")
      self.assert(response.bodyText, equals: "Test")
    }
    TestFilter().preProcessWithBlock(request, response: response, callback: callback) {
      _ = 1 + 1
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithBlockWithControllerErrorHaltsProcessing() {
    let expectation = expectationWithDescription("callback called")
    let request = Request(path: "/test/path")
    var response = Response()
    response.appendString("Test")
    
    let callback = {
      (request: Request, response: Response, stop: Bool) in
      expectation.fulfill()
      self.assert(stop, message: "Halts processing")
      self.assert(request.path, equals: "/test/path")
      self.assert(response.bodyText, equals: "Test 2")
    }
    TestFilter().preProcessWithBlock(request, response: response, callback: callback) {
      var response = Response()
      response.appendString("Test 2")
      throw ControllerError.UnprocessableRequest(response)
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
  
  func testPreProcessWithBlockWithNsErrorContinuesProcessing() {
    let expectation = expectationWithDescription("callback called")
    let request = Request(path: "/test/path")
    var response = Response()
    response.appendString("Test")
    
    enum CustomError: ErrorType {
      case MyError
    }
    let callback = {
      (request: Request, response: Response, stop: Bool) in
      expectation.fulfill()
      self.assert(!stop, message: "Allows processing to continue")
      self.assert(request.path, equals: "/test/path")
      self.assert(response.bodyText, equals: "Test")
    }
    TestFilter().preProcessWithBlock(request, response: response, callback: callback) {
      NSLog("About to throw error!")
      throw NSError(domain: "tailorframe.work", code: 1, userInfo: [:])
    }
    waitForExpectationsWithTimeout(0, handler: nil)
  }
}