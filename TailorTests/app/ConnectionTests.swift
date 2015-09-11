import XCTest
@testable import Tailor
import TailorTesting

class ConnectionTests: XCTestCase, TailorTestable {
  var requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body"]
  var requestData: [NSData] { return requestContents.map { NSData(bytes: $0.utf8) } }
  
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
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
  
  func testReadFromSocketCreatesRequestFromContents() {
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: "Request Body")
      self.assert(request.headers["Header"], equals: "Value")
      self.assert(request.clientAddress, equals: "3.4.5.6")
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketCanHandleRequestThatExceedsBuffer() {
    let body = "Request Body " + Array<String>(count: 205, repeatedValue: "1234").joinWithSeparator(" ")
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 1037\r\nHeader-2: Value 2\r\n\r\n" + body]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: body)
      self.assert(request.headers["Header"], equals: "Value")
      self.assert(request.clientAddress, equals: "3.4.5.6")
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketCanHandleChunkedRequest() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12", "\r\nHeader-2: Value 2\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: "Request Body")
      self.assert(request.headers["Header-2"], equals: "Value 2")
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWithContentLengthAfterFirstChunkHasEmptyBody() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\n", "Content-Length: 12", "\r\nHeader-2:Value 2\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: "")
      self.assert(isNil: request.headers["Header-2"])
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketStopsReadingOnceContentLengthIsExceeded() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body 1234", "Extra Text"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.bodyText, equals: "Request Body")
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWithContentLengthThatExceedsStreamDoesNotRespond() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 120\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      self.assert(false, message: "Should not respond")
    }
    
    connection.readFromSocket(123)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWithChunkedTransferReadsChunks() {
    requestContents = [
      "GET / HTTP/1.1\r\nHeader: Value\r\nTransfer-Encoding: chunked\r\n\r\n10\r\nWho",
      " am I?\r\nYou  \r\n4\r\nask?\r\n",
      "7\r\n No one\r\n0\r\n4\r\n",
      "More\r\n"
    ]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      self.assert(request.headers["Content-Length"], equals: "27")
      self.assert(request.bodyText, equals: "Who am I?\r\nYou  ask? No one")
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWritesResponseBackToSocket() {
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      var response = Response()
      response.headers["Test"] = "value"
      response.appendString("Hello")
      callback(response)
      self.assert(Connection.outputData, equals: response.data)
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWithExpectsContinueForValidPathWrites100Response() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nExpect: 100-continue\r\nContent-Length: 12\r\n\r\n", "Request Body"]
    Connection.startStubbing(requestData)
    RouteSet.load {
      (inout routes: RouteSet) in
      routes.addRoute(.Get("")) {
        request, callback in
      }
    }
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
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
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWithExpectsContinueForInvalidPathWrites404Response() {
    requestContents = ["GET /foo HTTP/1.1\r\nHeader: Value\r\nExpect: 100-continue\r\nContent-Length: 12\r\n\r\n", "Request Body"]
    Connection.startStubbing(requestData)
    RouteSet.load {
      (inout routes: RouteSet) in
      routes.addRoute(.Get("")) {
        request, callback in
      }
    }
    let expectation = expectationWithDescription("received request")
    var connection = Connection(fileDescriptor: -1) {
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
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWithoutExplicitClosingDoesNotCloseConnection() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body", "foo"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    var responded = false
    var connection = Connection(fileDescriptor: -1) {
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
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketCanReadMultipleRequests() {
    requestContents = [
      "GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 14\r\n\r\nRequest Body 1",
      "GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 14\r\n\r\nRequest Body 2"
    ]
    Connection.startStubbing(requestData)
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      var response = Response()
      response.appendString(request.bodyText)
      callback(response)
    }
    
    connection.readFromSocket(123)
    let date = Timestamp.now().inTimeZone("GMT").format(TimeFormat.Rfc822)
    let responses = "HTTP/1.1 200 OK\r\nDate: \(date)\r\nContent-Length: 14\r\nContent-Type: text/html; charset=UTF-8\r\n\r\nRequest Body 1HTTP/1.1 200 OK\r\nDate: \(date)\r\nContent-Length: 14\r\nContent-Type: text/html; charset=UTF-8\r\n\r\nRequest Body 2"
    assert(Connection.outputData, equals: NSData(bytes: responses.utf8))
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWithCloseFromRequestClosesConnection() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nConnection: close\r\nContent-Length: 12\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      var response = Response()
      response.headers["Test"] = "value"
      response.appendString("Hello")
      callback(response)
      self.assert(Connection.closedConnections, equals: [123])
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
  
  func testReadFromSocketWithCloseFromResponseClosesConnection() {
    requestContents = ["GET / HTTP/1.1\r\nHeader: Value\\r\nContent-Length: 12\r\n\r\nRequest Body"]
    Connection.startStubbing(requestData)
    let expectation = expectationWithDescription("received request")
    
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      expectation.fulfill()
      var response = Response()
      response.headers["Test"] = "value"
      response.headers["Connection"] = "close"
      response.appendString("Hello")
      callback(response)
      self.assert(Connection.closedConnections, equals: [123])
    }
    
    connection.readFromSocket(123)
    waitForExpectationsWithTimeout(0, handler: nil)
    Connection.stopStubbing()
  }
    
  //MARK: - Testing with Real IO
  
  func testCanReadRequestWithFileDescriptors() {
    let fileContents = "GET / HTTP/1.1\r\nHeader: Value\r\nConnection: close\r\nContent-Length: 12\r\n\r\nRequest Body"
    let path = Application.sharedApplication().rootPath() + "/connection.txt"
    let expectation = expectationWithDescription("callback called")
    var responded = false
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
      if responded { return }
      responded = true
      expectation.fulfill()
      self.assert(request.data, equals: NSData(bytes: fileContents.utf8))
      
      var response = Response()
      response.appendString("My Response")
      callback(response)
      let writtenData = NSData(contentsOfFile: path)!
      let combinedData = NSMutableData()
      combinedData.appendData(request.data)
      combinedData.appendData(response.data)
      self.assert(writtenData, equals: combinedData)
    }
    NSData(bytes: fileContents.utf8).writeToFile(path, atomically: true)
    guard let connectionHandle = NSFileHandle(forUpdatingAtPath: path) else { NSLog("Handle failed"); return }
    connection.readFromSocket(connectionHandle.fileDescriptor)
    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
