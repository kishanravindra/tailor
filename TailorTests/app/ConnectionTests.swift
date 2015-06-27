import XCTest
import Tailor
import TailorTesting

class ConnectionTests: TailorTestCase {
  var handler: Connection.RequestHandler = {
    (request, callback) in
  }
  var connection : Connection!
  var path = "connection_test.txt"
  var fileContents = "GET / HTTP/1.1\r\nHeader: Value\r\nContent-Length: 12\r\n\r\nRequest Body"
  var connectionHandle = NSFileHandle()
  
  func setUpConnection() {
    path = Application.sharedApplication().rootPath() + "/" + path
    connection = Connection(fileDescriptor: 0, handler: self.handler)
    fileContents.dataUsingEncoding(NSUTF8StringEncoding)?.writeToFile(path, atomically: true)
    guard let connectionHandle = NSFileHandle(forUpdatingAtPath: path) else { NSLog("Handle failed"); return }
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
      var response = Response()
      response.appendString("My Response")
      callback(response)
      let writtenData = NSData(contentsOfFile: self.path)!
      let combinedData = NSMutableData()
      combinedData.appendData(request.data)
      combinedData.appendData(response.data)
      if writtenData == combinedData {
        dataExpectation.fulfill()
      }
    }
    setUpConnection()
    self.waitForExpectationsWithTimeout(0.5) { error in return }
  }
}
