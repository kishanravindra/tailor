import XCTest
@testable import Tailor
import TailorTesting

class ConnectionTests: TailorTestCase {
  var requestContents = ["GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body"]
  var requestData: [NSData] { return requestContents.map { NSData(bytes: $0.utf8) } }
  
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
    let body = "Request Body " + " ".join(Array<String>(count: 205, repeatedValue: "1234"))
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
    
  //MARK: - Testing with Real IO
  
  func testCanReadRequestWithFileDescriptors() {
    let fileContents = "GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body"
    let path = Application.sharedApplication().rootPath() + "/connection.txt"
    let expectation = expectationWithDescription("callback called")
    var connection = Connection(fileDescriptor: -1) {
      request, callback in
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
    fileContents.dataUsingEncoding(NSUTF8StringEncoding)?.writeToFile(path, atomically: true)
    guard let connectionHandle = NSFileHandle(forUpdatingAtPath: path) else { NSLog("Handle failed"); return }
    connection.readFromSocket(connectionHandle.fileDescriptor)
    waitForExpectationsWithTimeout(1, handler: nil)
  }
}
