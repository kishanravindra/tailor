import XCTest
import Tailor
import TailorTesting
import Foundation

struct TestShaPasswordHasher: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testInitWithoutComponentsGeneratesRandomSalt", testInitWithoutComponentsGeneratesRandomSalt),
    ("testEncryptGeneratesTheSameValueForSameSalt", testEncryptGeneratesTheSameValueForSameSalt),
    ("testEncryptGeneratesTheSameValueForSameEncryptor", testEncryptGeneratesTheSameValueForSameEncryptor),
    ("testEncryptGeneratesDifferentValuesForDifferentPasswords", testEncryptGeneratesDifferentValuesForDifferentPasswords),
    ("testEncryptWithNonUtf8CompliantStringMatchsAnyOtherNonUtf8CompliantString", testEncryptWithNonUtf8CompliantStringMatchsAnyOtherNonUtf8CompliantString),
    ("testExtractSaltWithValidStringGetsSalt", testExtractSaltWithValidStringGetsSalt),
    ("testExtractSaltWithMalformedHashReturnsNil", testExtractSaltWithMalformedHashReturnsNil),
    ("testCanRecognizeCorrectPassword", testCanRecognizeCorrectPassword),
    ("testCanRejectIncorrectPassword", testCanRejectIncorrectPassword),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func testInitWithoutComponentsGeneratesRandomSalt() {
    let encryptor1 = ShaPasswordHasher()
    let encryptor2 = ShaPasswordHasher()
    assert(encryptor1.salt, doesNotEqual: encryptor2.salt, message: "generates different salts")
  }
  
  func testEncryptGeneratesTheSameValueForSameSalt() {
    var salt = [UInt8]()
    for byte in 0..<128 { salt.append(UInt8(byte)) }
    let saltData = NSData(bytes: salt)
    let encryptor1 = ShaPasswordHasher(salt: saltData)
    let encryptor2 = ShaPasswordHasher(salt: saltData)
    let value1 = encryptor1.encrypt("12341234")
    let value2 = encryptor2.encrypt("12341234")
    assert(value1, equals: value2, message: "generates the same hashed value")
  }
  
  func testEncryptGeneratesTheSameValueForSameEncryptor() {
    let encryptor = ShaPasswordHasher()
    let value1 = encryptor.encrypt("test")
    let value2 = encryptor.encrypt("test")
    assert(value1, equals: value2, message: "generates the same hashed value")
  }
  
  func testEncryptGeneratesDifferentValuesForDifferentPasswords() {
    let encryptor = ShaPasswordHasher()
    let value1 = encryptor.encrypt("test")
    let value2 = encryptor.encrypt("test2")
    assert(value1, doesNotEqual: value2, message: "generates different hashed value for different passwords")
  }
  
  func testEncryptWithNonUtf8CompliantStringMatchsAnyOtherNonUtf8CompliantString() {
    let data1 = NSData(bytes: [0xD8, 0x00])
    let data2 = NSData(bytes: [0xD8, 0x00, 0x10])
    guard let string1 = NSString(data: data1, encoding: NSUTF16LittleEndianStringEncoding)?.bridge() else {
      XCTFail("Could not create non-UTF8 string")
      return
    }
    guard let string2 = NSString(data: data2, encoding: NSUTF16LittleEndianStringEncoding)?.bridge() else {
      XCTFail("Could not create non-UTF8 string")
      return
    }
    let encryptor = ShaPasswordHasher()
    let value1 = encryptor.encrypt(string1)
    let value2 = encryptor.encrypt(string2)
    assert(value1, equals: value2, message: "Same encryptor generates same hashed value for different strings")
  }
  
  func testExtractSaltWithValidStringGetsSalt() {
    var salt = [UInt8]()
    for byte in 0..<16 { salt.append(UInt8(byte)) }
    let saltData = NSData(bytes: salt)
    let encryptor = ShaPasswordHasher(salt: saltData)
    let encryptedPassword = encryptor.encrypt("12341234")
    assert(ShaPasswordHasher.extractSalt(encryptedPassword), equals: saltData)
  }
  
  func testExtractSaltWithMalformedHashReturnsNil() {
    assert(isNil: ShaPasswordHasher.extractSalt("test"))
  }
  
  func testCanRecognizeCorrectPassword() {
    let encrypted = ShaPasswordHasher().encrypt("12341234")
    assert(ShaPasswordHasher.isMatch("12341234", encryptedPassword: encrypted))
  }
  
  func testCanRejectIncorrectPassword() {
    let encrypted = ShaPasswordHasher().encrypt("12341234")
    assert(!ShaPasswordHasher.isMatch("12341235", encryptedPassword: encrypted))
  }
}
