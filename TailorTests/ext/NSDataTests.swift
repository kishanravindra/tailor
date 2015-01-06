import XCTest

class NSDataTests: XCTestCase {
  func testInitializeSetsBytes() {
    let bytes : [UInt8] = [1,2,3,4,5]
    let data = NSData(bytes: bytes)
    XCTAssertEqual(data.length, 5, "gets five bytes")
    if data.length == 5 {
      var destinationBytes = [UInt8](count: 5, repeatedValue: 0)
      data.getBytes(UnsafeMutablePointer(destinationBytes), length: 5)
      XCTAssertEqual(destinationBytes, [1,2,3,4,5], "gets the 5 input bytes")
    }
  }
  
  func testComponentsSeparatedByStringGetsComponentsSpearatedByThatString() {
    let bytes : [UInt8] = [1,192,14,148,13,10,95,10,13,179,13,10,11,54,89]
    let data = NSData(bytes: UnsafePointer(bytes), length: sizeof(UInt8) * bytes.count)
    let components = data.componentsSeparatedByString("\r\n")
    XCTAssertEqual(components.count, 3, "gets three components")
    if components.count == 3 {
      XCTAssertEqual(components[0], NSData(bytes: [1,192,14,148]), "gets the first component")
      XCTAssertEqual(components[1], NSData(bytes: [95,10,13,179]), "gets the second component")
      XCTAssertEqual(components[2], NSData(bytes: [11,54,89]), "gets the second component")
    }
  }
  
  func testComponentsSeparatedByStringWithLimitCombinesFinalComponents() {
    let bytes : [UInt8] = [1,192,14,148,13,10,95,10,13,179,13,10,11,54,89]
    let data = NSData(bytes: UnsafePointer(bytes), length: sizeof(UInt8) * bytes.count)
    let components = data.componentsSeparatedByString("\r\n", limit: 2)
    XCTAssertEqual(components.count, 2, "gets two components")
    if components.count == 2 {
      XCTAssertEqual(components[0], NSData(bytes: [1,192,14,148]), "gets the first component")
      XCTAssertEqual(components[1], NSData(bytes: [95,10,13,179, 13, 10, 11, 54, 89]), "gets the second component")
    }
  }
}
