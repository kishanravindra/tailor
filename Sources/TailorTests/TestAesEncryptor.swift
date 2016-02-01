import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestAesEncryptor: XCTestCase, TailorTestable {
  //MARK: - Encodings
  
  var allTests: [(String, () throws -> Void)] { return [      
      ("testGetHexStringWorksForSingleDigit", testGetHexStringWorksForSingleDigit),
      ("testGetHexStringWorksForMultipleDigits", testGetHexStringWorksForMultipleDigits),
      ("testGetHexStringWorksForMultipleUnpaddedDigits", testGetHexStringWorksForMultipleUnpaddedDigits),
      ("testGetHexWorksForSingleDigit", testGetHexWorksForSingleDigit),
      ("testGetHexWorksForMultipleDigits", testGetHexWorksForMultipleDigits),
      ("testGetHexHandlesInvalidValues", testGetHexHandlesInvalidValues),
      ("testEncryptIsReversible", testEncryptIsReversible),
      ("testEncryptIsNotIdempotent", testEncryptIsNotIdempotent),
      ("testInitializationWithEmptyKeyIsNil", testInitializationWithEmptyKeyIsNil),
      ("testGenerateKeyGetsHexString", testGenerateKeyGetsHexString),
  ]  }

  func setUp() {
    setUpTestCase()
  }
  
  func testGetHexStringWorksForSingleDigit() {
    assert(AesEncryptor.getHexString(1, pad: true), equals: "01", message: "gets padded single digit")
    assert(AesEncryptor.getHexString(5, pad: false), equals: "5", message: "gets unpadded single")
    assert(AesEncryptor.getHexString(12, pad: false), equals: "C", message: "gets digit higher than 10")
  }
  
  func testGetHexStringWorksForMultipleDigits() {
    assert(AesEncryptor.getHexString(198), equals: "C6", message: "gets multiple digits")
  }
  
  func testGetHexStringWorksForMultipleUnpaddedDigits() {
    assert(AesEncryptor.getHexString(198, pad: false), equals: "C6", message: "gets multiple digits")
  }
  
  func testGetHexWorksForSingleDigit() {
    let value1 = AesEncryptor.getHex("5")
    assert(value1, equals: UInt8(5), message: "gets single digit")
    
    let value2 = AesEncryptor.getHex("F")
    assert(value2, equals: UInt8(15), message: "gets single digit over 10")
  }
  
  func testGetHexWorksForMultipleDigits() {
    assert(AesEncryptor.getHex("09"), equals: UInt8(9), message: "gets multiple digits with a 0")
    assert(AesEncryptor.getHex("14"), equals: UInt8(20), message: "gets multiple digits with another digit")
    assert(AesEncryptor.getHex("A5"), equals: UInt8(165), message: "gets multiple digits with a leading digit over 10")
  }
  
  func testGetHexHandlesInvalidValues() {
    assert(AesEncryptor.getHex("") == nil, message: "returns nil for an empty string")
    assert(AesEncryptor.getHex("105") == nil, message: "returns nil for a string with more than two digits")
    assert(AesEncryptor.getHex("Z") == nil, message: "returns nil with a non-hex character")
    assert(AesEncryptor.getHex("ZZ") == nil, message: "returns nil with multiple non-hex character")
    assert(AesEncryptor.getHex("0Z") == nil, message: "returns nil with a non-hex character and a hex character")
  }
  
  //MARK: - Encryption
  
  func testEncryptIsReversible() {
    let encryptor = AesEncryptor(key: AesEncryptor.generateKey())!
    let inputData = NSData(bytes: "test data".utf8)
    let value = encryptor.encrypt(inputData)
    let decryptedValue = encryptor.decrypt(value)
    let string = NSString(data: decryptedValue, encoding: NSUTF8StringEncoding)
    assert(string, equals: "test data", message: "gets original data back")
  }
  
  func testEncryptIsNotIdempotent() {
    let encryptor = AesEncryptor(key: AesEncryptor.generateKey())!
    let inputData = NSData(bytes: "test data".utf8)
    let value1 = encryptor.encrypt(inputData)
    print("Encrypted value is \(value1)")
    let value2 = encryptor.encrypt(inputData)
    assert(value1, doesNotEqual: value2, message: "gets different encrypted data each time")
  }
  
  func testInitializationWithEmptyKeyIsNil() {
    let encryptor = AesEncryptor(key: "")
    assert(isNil: encryptor)
  }
  
  func testGenerateKeyGetsHexString() {
    let string = AesEncryptor.generateKey()
    assert(string.characters.count, equals: 64, message: "is a 64 character string")
    let regex: NSRegularExpression?
    do {
      regex = try NSRegularExpression(pattern: "^[A-F0-9]*$", options: [])
    } catch _ {
      regex = nil
    }
    let matchCount = regex?.numberOfMatchesInString(string, options: [], range: NSMakeRange(0, string.characters.count)) ?? 0
    assert(matchCount, equals: 1, message: "matches hex regex")
  }
}
