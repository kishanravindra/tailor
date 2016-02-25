import XCTest
@testable import Tailor
import TailorTesting
import Foundation

final class TestConnection: XCTestCase, TailorTestable {
  var requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body"]
  var requestData: [NSData] { return requestContents.map { NSData(bytes: $0.utf8) } }
  
  func setUp() {
    setUpTestCase()
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body"]
  }

  var allTests: [(String, () throws -> Void)] { return [ 
      ("testInitializerStartsListening", testInitializerStartsListening),
      ("testReadRequestFromSocketCreatesRequestFromContents", testReadRequestFromSocketCreatesRequestFromContents),
      ("testReadRequestFromSocketCanHandleRequestThatExceedsBuffer", testReadRequestFromSocketCanHandleRequestThatExceedsBuffer),
      ("testReadRequestFromSocketCanHandleChunkedRequest", testReadRequestFromSocketCanHandleChunkedRequest),
      ("testReadRequestFromSocketWithContentLengthAfterFirstChunkHasEmptyBody", testReadRequestFromSocketWithContentLengthAfterFirstChunkHasEmptyBody),
      ("testReadRequestFromSocketStopsReadingOnceContentLengthIsExceeded", testReadRequestFromSocketStopsReadingOnceContentLengthIsExceeded),
      ("testReadRequestFromSocketWithContentLengthThatExceedsStreamDoesNotRespond", testReadRequestFromSocketWithContentLengthThatExceedsStreamDoesNotRespond),
      ("testReadRequestFromSocketWithChunkedTransferReadsChunks", testReadRequestFromSocketWithChunkedTransferReadsChunks),
      ("testReadRequestFromSocketWritesResponseBackToSocket", testReadRequestFromSocketWritesResponseBackToSocket),
      ("testReadRequestFromSocketWithExpectsContinueForValidPathWrites100Response", testReadRequestFromSocketWithExpectsContinueForValidPathWrites100Response),
      ("testReadRequestFromSocketWithExpectsContinueForInvalidPathWrites404Response", testReadRequestFromSocketWithExpectsContinueForInvalidPathWrites404Response),
      ("testReadRequestFromSocketWithoutExplicitClosingDoesNotCloseConnection", testReadRequestFromSocketWithoutExplicitClosingDoesNotCloseConnection),
      ("testReadRequestFromSocketCanReadMultipleRequests", testReadRequestFromSocketCanReadMultipleRequests),
      ("testReadRequestFromSocketWithCloseFromRequestClosesConnection", testReadRequestFromSocketWithCloseFromRequestClosesConnection),
      ("testReadRequestFromSocketWithCloseFromResponseClosesConnection", testReadRequestFromSocketWithCloseFromResponseClosesConnection),
      ("testReadRequestFromSocketWithChunkedResponseWritesMultipleChunks", testReadRequestFromSocketWithChunkedResponseWritesMultipleChunks),
      ("testCanReadRequestWithFileDescriptors", testCanReadRequestWithFileDescriptors),
      ("testCanDetectClosedPipeInContinuationCallback", testCanDetectClosedPipeInContinuationCallback),
      ("testSendRequestCanMakeHttpRequestToRealDomain", testSendRequestCanMakeHttpRequestToRealDomain),
      ("testSendRequestCanMakeSynchronousHttpRequestToRealDomain", testSendRequestCanMakeSynchronousHttpRequestToRealDomain),
      ("testSendRequestCanMakeHttpsRequestToRealDomain", testSendRequestCanMakeHttpsRequestToRealDomain),
      ("testSendRequestCanMakeSynchronousHttpsRequestToRealDomain", testSendRequestCanMakeSynchronousHttpsRequestToRealDomain),
  ] }
  //MARK: - Reading from Socket
  
  func testInitializerStartsListening() {
    let expectation = expectationWithDescription("received connection")
    Connection.startStubbing(requestData)

    _ = Connection(fileDescriptor: 123) {
      request, callback in
      expectation.fulfill()
      self.assert(Connection.acceptedSockets, equals: [123])
      self.assert(Connection.readConnections, equals: [124])
    }
    waitForExpectationsWithTimeout(1, handler: nil)
    Connection.stopStubbing()
  }

  func testReadRequestFromSocketCreatesRequestFromContents() {
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: "Request Body")
      self.assert(request.headers["Header"], equals: "Value")
      self.assert(request.clientAddress, equals: "3.4.5.6")
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }

  func testReadRequestFromSocketCanHandleRequestThatExceedsBuffer() {
    let body = "Request Body " + Array<String>(count: 205, repeatedValue: "1234").joinWithSeparator(" ")
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 1037\r\nHeader-2: Value 2\r\n\r\n" + body]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: body)
      self.assert(request.headers["Header"], equals: "Value")
      self.assert(request.clientAddress, equals: "3.4.5.6")
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketCanHandleChunkedRequest() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12", "\r\nHeader-2: Value 2\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: "Request Body")
      self.assert(request.headers["Header-2"], equals: "Value 2")
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithContentLengthAfterFirstChunkHasEmptyBody() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\n", "Content-Length: 12", "\r\nHeader-2:Value 2\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: "")
      self.assert(isNil: request.headers["Header-2"])
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketStopsReadingOnceContentLengthIsExceeded() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body 1234", "Extra Text"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: "Request Body")
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithContentLengthThatExceedsStreamDoesNotRespond() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 120\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      self.assert(false, message: "Should not respond")
    }
    
    connection.readRequestFromSocket(123)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithChunkedTransferReadsChunks() {
    requestContents = [
      "GET / HTTP/1.1\r\nHeader: Value\r\nTransfer-Encoding: chunked\r\n\r\n10\r\nWho",
      " am I?\r\nYou  \r\n4\r\nask?\r\n",
      "7\r\n No one\r\n0\r\n4\r\n",
      "More\r\n"
    ]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")

    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.headers["Content-Length"], equals: "27")
      self.assert(request.bodyText, equals: "Who am I?\r\nYou  ask? No one")
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWritesResponseBackToSocket() {
    setUp()
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      var response = Response()
      response.headers["Test"] = "value"
      response.appendString("Hello")
      callback(response)
      self.assert(Connection.outputData, equals: response.data)
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithExpectsContinueForValidPathWrites100Response() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nExpect: 100-continue\r\nContent-Length: 12\r\n\r\n", "Request Body"]
    Connection.startStubbing(requestData)
    RouteSet.load {
      (inout routes: RouteSet) in
      routes.addRoute(.Get("")) {
        request, callback in
      }
    }
    let expectation = expectationWithDescription("received request")
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      var continueResponse = Response()
      continueResponse.responseCode = .Continue
      var response = Response()
      response.responseCode = .Ok
      response.headers["Test"] = "value"
      response.appendString("Hello")
      callback(response)
      let expectedData = NSMutableData()
      expectedData.appendData(continueResponse.data)
      expectedData.appendData(continueResponse.data)
      expectedData.appendData(response.data)
      self.assert(Connection.outputData, equals: expectedData)
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithExpectsContinueForInvalidPathWrites404Response() {
    requestContents = ["GET /foo HTTP/1.1\r\nHeader: Value\r\nExpect: 100-continue\r\nContent-Length: 12\r\n\r\n", "Request Body"]
    Connection.startStubbing(requestData)
    RouteSet.load {
      (inout routes: RouteSet) in
      routes.addRoute(.Get("")) {
        request, callback in
      }
    }
    let expectation = expectationWithDescription("received request")
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      var continueResponse = Response()
      continueResponse.responseCode = .NotFound
      var response = Response()
      response.responseCode = .Ok
      response.headers["Test"] = "value"
      response.appendString("Hello")
      callback(response)
      let expectedData = NSMutableData()
      expectedData.appendData(continueResponse.data)
      expectedData.appendData(continueResponse.data)
      expectedData.appendData(response.data)
      self.assert(Connection.outputData, equals: expectedData)
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithoutExplicitClosingDoesNotCloseConnection() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body", "foo"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var responded = false
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      if responded { return }
      responded = true
      expectation.fulfill()
      var response = Response()
      response.headers["Test"] = "value"
      response.appendString("Hello")
      callback(response)
      self.assert(Connection.closedConnections.isEmpty)
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketCanReadMultipleRequests() {
    requestContents = [
      "GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 14\r\n\r\nRequest Body 1",
      "GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 14\r\n\r\nRequest Body 2"
    ]
    Connection.startStubbing(requestData)
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      var response = Response()
      response.appendString(request.bodyText)
      callback(response)
    }
    
    connection.readRequestFromSocket(123)
    let date = Timestamp.now().inTimeZone("GMT").format(TimeFormat.Rfc822)
    let responses = "HTTP/1.1 200 OK\r\nContent-Length: 14\r\nContent-Type: text/html; charset=UTF-8\r\nDate: \(date)\r\n\r\nRequest Body 1HTTP/1.1 200 OK\r\nContent-Length: 14\r\nContent-Type: text/html; charset=UTF-8\r\nDate: \(date)\r\n\r\nRequest Body 2"
    assert(Connection.outputData, equals: NSData(bytes: responses.utf8))
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithCloseFromRequestClosesConnection() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nConnection: close\r\nContent-Length: 12\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      var response = Response()
      response.headers["Test"] = "value"
      response.appendString("Hello")
      callback(response)
      self.assert(Connection.closedConnections, equals: [123])
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithCloseFromResponseClosesConnection() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\\r\nContent-Length: 12\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      var response = Response()
      response.headers["Test"] = "value"
      response.headers["Connection"] = "close"
      response.appendString("Hello")
      callback(response)
      self.assert(Connection.closedConnections, equals: [123])
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadRequestFromSocketWithChunkedResponseWritesMultipleChunks() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nConnection: close\r\nContent-Length: 12\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation1 = expectationWithDescription("received request")
    let expectation2 = expectationWithDescription("received continuation 1")
    let expectation3 = expectationWithDescription("received continuation 2")
    let expectation4 = expectationWithDescription("received continuation 3")
    
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation1.fulfill()
      var response = Response()
      response.headers["Test"] = "value"
      response.headers["Transfer-Encoding"] = "chunked"
      response.hasDefinedLength = false
      response.continuationCallback = {
        shouldContinue in
        self.assert(shouldContinue)
        self.assert(Connection.closedConnections.isEmpty)
        expectation2.fulfill()
        var response2 = Response()
        response2.headers["Transfer-Encoding"] = "chunked"
        response2.appendString("ABC123")
        response2.bodyOnly = true
        response2.hasDefinedLength = false
        response2.continuationCallback = {
          shouldContinue in
          self.assert(shouldContinue)
          self.assert(Connection.closedConnections.isEmpty)
          expectation3.fulfill()
          var response3 = Response()
          response3.headers["Transfer-Encoding"] = "chunked"
          response3.appendString("456")
          response3.bodyOnly = true
          response3.hasDefinedLength = false
          response3.continuationCallback = {
            shouldContinue in
            expectation4.fulfill()
            self.assert(shouldContinue)
            self.assert(Connection.closedConnections.isEmpty)
            var response4 = Response()
            response4.headers["Transfer-Encoding"] = "chunked"
            response4.bodyOnly = true
            response4.hasDefinedLength = false
            callback(response4)
          }
          callback(response3)
        }
        callback(response2)
      }
      callback(response)
      self.assert(Connection.closedConnections, equals: [123])
      let responseLines = NSString(data: Connection.outputData, encoding: NSUTF8StringEncoding)!.componentsSeparatedByString("\r\n")
      let time = Timestamp.now().inTimeZone("GMT").format(TimeFormat.Cookie)
      self.assert(responseLines, equals: [
        "HTTP/1.1 200 OK",
        "Content-Type: text/html; charset=UTF-8",
        "Date: \(time)",
        "Test: value",
        "Transfer-Encoding: chunked",
        "",
        "6",
        "ABC123",
        "3",
        "456",
        "0",
        "",
        ""
      ])
    }
    
    connection.readRequestFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
    
  //MARK: - Testing with Real IO
  
  func testCanReadRequestWithFileDescriptors() {
    let fileContents = "GET / HTTP/1.1\r\nHeader: Value\r\nConnection: close\r\nContent-Length: 12\r\n\r\nRequest Body"
    let fileData = NSData(bytes: fileContents.utf8)
    let path = Application.configuration.resourcePath + "/connection.txt"
    let expectation = expectationWithDescription("callback called")
    var responded = false
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      if responded { return }
      responded = true
      expectation.fulfill()
      self.assert(request.headers["Header"], equals: "Value")
      self.assert(request.bodyText, equals: "Request Body")
      
      var response = Response()
      response.appendString("My Response")
      callback(response)
      let writtenData = NSData(contentsOfFile: path)!
      let combinedData = NSMutableData()
      combinedData.appendData(fileData)
      combinedData.appendData(response.data)
      self.assert(writtenData, equals: combinedData)
    }
    fileData.writeToFile(path, atomically: true)
    guard let connectionHandle = NSFileHandle(forUpdatingAtPath: path) else { NSLog("Handle failed"); return }
    connection.readRequestFromSocket(connectionHandle.fileDescriptor)
    waitForExpectationsWithTimeout(1, handler: nil)
  }
  
  func testCanDetectClosedPipeInContinuationCallback() {
    let fileContents = "GET / HTTP/1.1\r\nHeader: Value\r\nConnection: close\r\nContent-Length: 12\r\n\r\nRequest Body"
    let fileData = NSData(bytes: fileContents.utf8)
    let path = Application.configuration.resourcePath + "/connection.txt"
    let expectation = expectationWithDescription("callback called")
    let expectation2 = expectationWithDescription("continuation called 1")
    let expectation3 = expectationWithDescription("continuation called 2")
    var responded = false
    var connectionHandle: NSFileHandle? = nil
    let connection = Connection(fileDescriptor: -1) {
      request, callback in
      if responded { return }
      responded = true
      expectation.fulfill()
      self.assert(request.bodyText, equals: "Request Body")
      
      var response = Response()
      response.appendString("My Response")
      response.hasDefinedLength = false
      response.continuationCallback = {
        shouldContinue in
        self.assert(shouldContinue)
        expectation2.fulfill()
        var response2 = Response()
        response2.appendString("Part Two")
        response2.hasDefinedLength = false
        response2.continuationCallback = {
          shouldContinue in
          expectation3.fulfill()
          self.assert(!shouldContinue)
        }
        connectionHandle?.closeFile()
        callback(response2)
      }
      callback(response)
    }
    fileData.writeToFile(path, atomically: true)
    connectionHandle = NSFileHandle(forUpdatingAtPath: path)
    connection.readRequestFromSocket(connectionHandle?.fileDescriptor ?? -1)
    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testSendRequestCanMakeHttpRequestToRealDomain() {
    let request = Request(domain: "tailorframe.work", path: "/", secure: false)
    let expectation = expectationWithDescription("callback called")
    Connection.sendRequest(request) {
      response in
      expectation.fulfill()
      self.assert(response.responseCode.code, equals: 301)
      self.assert(response.headers["Location"], equals: "https://tailorframe.work/")
      self.assert(response.bodyText, contains: "301 Moved Permanently")
    }
    waitForExpectationsWithTimeout(5, handler: nil)
  }

  func testSendRequestCanMakeHttpsRequestToRealDomain() {
    let request = Request(domain: "tailorframe.work", path: "/", secure: true)
    let expectation = expectationWithDescription("callback called")
    Connection.sendRequest(request) {
      response in
      expectation.fulfill()
      self.assert(response.responseCode.code, equals: 200)
      self.assert(response.bodyText, contains: "<title>Tailor</title>")
    }
    waitForExpectationsWithTimeout(5, handler: nil)
  }

  func testSendRequestCanMakeSynchronousHttpRequestToRealDomain() {
    let request = Request(domain: "tailorframe.work", path: "/", secure: false)
    var response = Connection.sendRequest(request)
    self.assert(response.responseCode.code, equals: 301)
    self.assert(response.headers["Location"], equals: "https://tailorframe.work/")
    self.assert(response.bodyText, contains: "301 Moved Permanently")
  }

  func testSendRequestCanMakeSynchronousHttpsRequestToRealDomain() {
    let request = Request(domain: "tailorframe.work", path: "/", secure: true)
    let response = Connection.sendRequest(request)
    self.assert(response.responseCode.code, equals: 200)
    self.assert(response.bodyText, contains: "<title>Tailor</title>")
    waitForExpectationsWithTimeout(5, handler: nil)
  }
}
