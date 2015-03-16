import XCTest
import Tailor

class AesEncryptorTests: XCTestCase {
  //MARK: - Encodings
  
  func testGetHexStringWorksForSingleDigit() {
    XCTAssertEqual(AesEncryptor.getHexString(1, pad: true), "01", "gets padded single digit")
    XCTAssertEqual(AesEncryptor.getHexString(5, pad: false), "5", "gets unpadded single")
    XCTAssertEqual(AesEncryptor.getHexString(12, pad: false), "C", "gets digit higher than 10")
  }
  
  func testGetHexStringWorksForMultipleDigits() {
    XCTAssertEqual(AesEncryptor.getHexString(198), "C6", "gets multiple digits")
  }
  
  func testGetHexWorksForSingleDigit() {
    if let value = AesEncryptor.getHex("5") {
      XCTAssertEqual(value, UInt8(5), "gets single digit")
    }
    else {
      XCTFail()
    }
    
    if let value = AesEncryptor.getHex("F") {
      XCTAssertEqual(value, UInt8(15), "gets single digit over 10")
    }
    else {
      XCTFail()
    }
  }
  
  func testGetHexWorksForMultipleDigits() {
    if let value = AesEncryptor.getHex("09") {
      XCTAssertEqual(value, UInt8(9), "gets multiple digits with a 0")
    }
    else {
      XCTFail()
    }
    
    if let value = AesEncryptor.getHex("14") {
      XCTAssertEqual(value, UInt8(20), "gets multiple digits with another digit")
    }
    else {
      XCTFail()
    }
    
    if let value = AesEncryptor.getHex("A5") {
      XCTAssertEqual(value, UInt8(165), "gets multiple digits with a leading digit over 10")
    }
    else {
      XCTFail()
    }
  }
  
  func testGetHexHandlesInvalidValues() {
    XCTAssertTrue(AesEncryptor.getHex("") == nil, "returns nil for an empty string")
    XCTAssertTrue(AesEncryptor.getHex("105") == nil, "returns nil for a string with more than two digits")
    XCTAssertTrue(AesEncryptor.getHex("Z") == nil, "returns nil with a non-hex character")
    XCTAssertTrue(AesEncryptor.getHex("ZZ") == nil, "returns nil with multiple non-hex character")
    XCTAssertTrue(AesEncryptor.getHex("0Z") == nil, "returns nil with a non-hex character and a hex character")
  }
  
  //MARK: - Encryption
  
  func testEncryptIsReversible() {
    let encryptor = AesEncryptor(key: AesEncryptor.generateKey())
    let inputData = "test data".dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    let value = encryptor.encrypt(inputData)
    let decryptedValue = encryptor.decrypt(value)
    let string = NSString(data: decryptedValue, encoding: NSUTF8StringEncoding)
    XCTAssertNotNil(string, "gets original data back")
    if string != nil { XCTAssertEqual(string!, "test data", "gets original data back") }
  }
  
  func testEncryptIsIdempotent() {
    let encryptor = AesEncryptor(key: AesEncryptor.generateKey())
    let inputData = "test data".dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    let value1 = encryptor.encrypt(inputData)
    let value2 = encryptor.encrypt(inputData)
    XCTAssertEqual(value1, value2, "gets the same data both times")
  }
  
  func testGenerateKeyGetsHexString() {
    let string = AesEncryptor.generateKey()
    XCTAssertEqual(countElements(string), 64, "is a 64 character string")
    let regex = NSRegularExpression(pattern: "^[A-F0-9]*$", options: nil, error: nil)
    let matchCount = regex?.numberOfMatchesInString(string, options: nil, range: NSMakeRange(0, countElements(string))) ?? 0
    XCTAssertEqual(matchCount, 1, "matches hex regex")
  }
}
