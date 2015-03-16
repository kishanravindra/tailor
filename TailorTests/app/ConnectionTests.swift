import XCTest
import Tailor

class ConnectionTests: XCTestCase {
  class TestConnection : Connection {
    override func listenToSocket() {
    }
  }
  var handler: Server.RequestHandler = {
    (request, callback) in
  }
  var connection : TestConnection!
  var path = "./build/connection_test.txt"
  var fileContents = "GET / HTTP/1.1\r\nHeader: Value\r\n\r\nRequest Body"
  var connectionHandle = NSFileHandle()
  
  func setUpConnection() {
    connection = TestConnection(fileDescriptor: 0, handler: self.handler)
    fileContents.dataUsingEncoding(NSUTF8StringEncoding)?.writeToFile(path, atomically: true)
    connectionHandle = NSFileHandle(forUpdatingAtPath: path)!
    connection.readFromSocket(connectionHandle.fileDescriptor)
  }
  
  func testCanReceiveConnection() {
    let expectation = expectationWithDescription("received connection")
    
    handler = {
      (request, callback) in
      expectation.fulfill()
    }
    
    setUpConnection()
    self.waitForExpectationsWithTimeout(0.5) {
      (error) in
    }
  }
  
  func testGivesRequestToHandler() {
    let receivedExpectation = expectationWithDescription("received request")
    let dataExpectation = expectationWithDescription("received data")
    handler = {
      (request, callback) in
      receivedExpectation.fulfill()
      if request.data == self.fileContents.dataUsingEncoding(NSUTF8StringEncoding) {
        dataExpectation.fulfill()
      }
    }
    setUpConnection()
    self.waitForExpectationsWithTimeout(0.5) {
      (error) in
    }
  }
  
  func testWritesResponseToSocket() {
    let dataExpectation = expectationWithDescription("wrote data to file")
    handler = {
      (request, callback) in
      self.connectionHandle.truncateFileAtOffset(0)
      let response = Response()
      response.appendString("My Response")
      callback(response)
      let writtenData = NSData(contentsOfFile: self.path)!
      if writtenData == response.data {
        dataExpectation.fulfill()
      }
    }
    setUpConnection()
    self.waitForExpectationsWithTimeout(0.5) { error in return }
  }
}
