import XCTest
import Tailor
import TailorTesting

class PasswordHasherTests: XCTestCase, TailorTestable {
  override func setUp() {
    super.setUp()
    setUpTestCase()
  }
  
  func testInitWithoutComponentsGeneratesRandomSalt() {
    let encryptor1 = PasswordHasher()
    let encryptor2 = PasswordHasher()
    let value1 = encryptor1.encrypt("test")
    let value2 = encryptor2.encrypt("test")
    XCTAssertNotEqual(value1, value2, "generates different hashed values")
  }
  
  func testEncryptGeneratesTheSameValueForSameSalt() {
    var salt = [UInt8]()
    for byte in 0..<128 { salt.append(UInt8(byte)) }
    let saltData = NSData(bytes: salt)
    let encryptor1 = PasswordHasher(salt: saltData)
    let encryptor2 = PasswordHasher(salt: saltData)
    let value1 = encryptor1.encrypt("12341234")
    let value2 = encryptor2.encrypt("12341234")
    assert(value1, equals: value2, message: "generates the same hashed value")
  }
  
  func testEncryptGeneratesTheSameValueForSameEncryptor() {
    let encryptor = PasswordHasher()
    let value1 = encryptor.encrypt("test")
    let value2 = encryptor.encrypt("test")
    assert(value1, equals: value2, message: "generates the same hashed value")
  }
  
  func testEncryptorCanRecognizeMatchingValues() {
    let value = PasswordHasher().encrypt("test1")
    XCTAssertTrue(PasswordHasher.isMatch("test1", encryptedHash: value), "accepts correct value")
    XCTAssertFalse(PasswordHasher.isMatch("test2", encryptedHash: value), "rejects incorrect value")
  }
  
  func testEncryptorWithNonUtf8CompliantStringMatchsAnyOtherNonUtf8CompliantString() {
    let data1 = NSData(bytes: [0xD8, 0x00])
    let data2 = NSData(bytes: [0xD8, 0x00, 0x10])
    let string1 = NSString(data: data1, encoding: NSUTF16BigEndianStringEncoding) as! String
    let string2 = NSString(data: data2, encoding: NSUTF16BigEndianStringEncoding) as! String
    let value = PasswordHasher().encrypt(string1)
    assert(PasswordHasher.isMatch(string2, encryptedHash: value))
  }
  
  func testIsMatchWithMalformedHashReturnsFalse() {
    let encryptedHash = PasswordHasher().encrypt("test")
    let badHash = "A" + encryptedHash.substringFromIndex(encryptedHash.startIndex.advancedBy(1))
    assert(!PasswordHasher.isMatch("test", encryptedHash: badHash))
  }
}
