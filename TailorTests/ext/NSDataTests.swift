import XCTest
import TailorTesting

class NSDataTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testInitializeSetsBytes() {
    let bytes : [UInt8] = [1,2,3,4,5]
    let data = NSData(bytes: bytes)
    assert(data.length, equals: 5, message: "gets five bytes")
    if data.length == 5 {
      let destinationBytes = [UInt8](count: 5, repeatedValue: 0)
      data.getBytes(UnsafeMutablePointer(destinationBytes), length: 5)
      assert(destinationBytes, equals: [1,2,3,4,5], message: "gets the 5 input bytes")
    }
  }
  
  func testComponentsSeparatedByStringGetsComponentsSpearatedByThatString() {
    let bytes : [UInt8] = [1,192,14,148,13,10,95,10,13,179,13,10,11,54,89]
    let data = NSData(bytes: UnsafePointer(bytes), length: sizeof(UInt8) * bytes.count)
    let components = data.componentsSeparatedByString("\r\n")
    assert(components.count, equals: 3, message: "gets three components")
    if components.count == 3 {
      assert(components[0], equals: NSData(bytes: [1,192,14,148]), message: "gets the first component")
      assert(components[1], equals: NSData(bytes: [95,10,13,179]), message: "gets the second component")
      assert(components[2], equals: NSData(bytes: [11,54,89]), message: "gets the second component")
    }
  }
  
  func testComponentsSeparatedByStringWithLimitCombinesFinalComponents() {
    let bytes : [UInt8] = [1,192,14,148,13,10,95,10,13,179,13,10,11,54,89]
    let data = NSData(bytes: UnsafePointer(bytes), length: sizeof(UInt8) * bytes.count)
    let components = data.componentsSeparatedByString("\r\n", limit: 2)
    assert(components.count, equals: 2, message: "gets two components")
    if components.count == 2 {
      assert(components[0], equals: NSData(bytes: [1,192,14,148]), message: "gets the first component")
      assert(components[1], equals: NSData(bytes: [95,10,13,179, 13, 10, 11, 54, 89]), message: "gets the second component")
    }
  }
  
  func testComponentsForEmptyDataReturnsArrayOfEmptyData() {
    let data = NSData()
    let components = data.componentsSeparatedByString("\r\n", limit: 2)
    assert(components, equals: [data], message: "returns the data in an array")
  }
  
  func testComponentsWithNonUtf8CompliantSeparatorReturnsOneComponent() {
    let bytes : [UInt8] = [1,192,14,148,13,10,95,10,13,179,13,10,11,54,89]
    let data = NSData(bytes: bytes)
    let separator = NSString(data: NSData(bytes: [0x0D, 0x0A, 0xD8, 0x00]), encoding: NSUTF16BigEndianStringEncoding) as! String
    let components = data.componentsSeparatedByString(separator)
    assert(components, equals: [data])
  }

  func testMd5HashGetsMd5Hash() {
    let data = NSData(bytes: "The quick brown fox jumps over the lazy dog".utf8)
    let hash = data.md5Hash
    assert(hash, equals: "9e107d9d372bb6826bd81d3542a419d6")
  }
}
