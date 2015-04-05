import XCTest
import Tailor
import TailorTesting

class AesEncryptorTests: TailorTestCase {
  //MARK: - Encodings
  
  func testGetHexStringWorksForSingleDigit() {
    assert(AesEncryptor.getHexString(1, pad: true), equals: "01", message: "gets padded single digit")
    assert(AesEncryptor.getHexString(5, pad: false), equals: "5", message: "gets unpadded single")
    assert(AesEncryptor.getHexString(12, pad: false), equals: "C", message: "gets digit higher than 10")
  }
  
  func testGetHexStringWorksForMultipleDigits() {
    assert(AesEncryptor.getHexString(198), equals: "C6", message: "gets multiple digits")
  }
  
  func testGetHexWorksForSingleDigit() {
    if let value = AesEncryptor.getHex("5") {
      assert(value, equals: UInt8(5), message: "gets single digit")
    }
    else {
      XCTFail()
    }
    
    if let value = AesEncryptor.getHex("F") {
      assert(value, equals: UInt8(15), message: "gets single digit over 10")
    }
    else {
      XCTFail()
    }
  }
  
  func testGetHexWorksForMultipleDigits() {
    assert(AesEncryptor.getHex("09"), equals: UInt8(9), message: "gets multiple digits with a 0")
    assert(AesEncryptor.getHex("14"), equals: UInt8(20), message: "gets multiple digits with another digit")
    assert(AesEncryptor.getHex("A5"), equals: UInt8(165), message: "gets multiple digits with a leading digit over 10")
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
    assert(string!, equals: "test data", message: "gets original data back")
  }
  
  func testEncryptIsIdempotent() {
    let encryptor = AesEncryptor(key: AesEncryptor.generateKey())
    let inputData = "test data".dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    let value1 = encryptor.encrypt(inputData)
    let value2 = encryptor.encrypt(inputData)
    assert(value1, equals: value2, message: "gets the same data both times")
  }
  
  func testGenerateKeyGetsHexString() {
    let string = AesEncryptor.generateKey()
    assert(count(string), equals: 64, message: "is a 64 character string")
    let regex = NSRegularExpression(pattern: "^[A-F0-9]*$", options: nil, error: nil)
    let matchCount = regex?.numberOfMatchesInString(string, options: nil, range: NSMakeRange(0, count(string))) ?? 0
    assert(matchCount, equals: 1, message: "matches hex regex")
  }
}
