import XCTest
import Tailor

class BlowfishEncryptorTests: XCTestCase {
  func testInitWithComponentsGeneratesSettingString() {
    var salt = [UInt8]()
    for byte in 0..<128 { salt.append(UInt8(byte)) }
    let encryptor = BcryptHasher(version: "b", salt: salt, rounds: 8)
    let value = encryptor.encrypt("test")!
    let settingString = value.substringToIndex(advance(value.startIndex, 29))
    XCTAssertEqual(settingString, "$2b$08$..CA.uOD/eaGAOmJB.yMBu", "sets the setting string to contain the version, number of rounds, and salt")
  }
  
  func testInitWithoutComponentsGeneratesRandomSalt() {
    var encryptor1 = BcryptHasher()
    var encryptor2 = BcryptHasher()
    let value1 = encryptor1.encrypt("test")!
    let value2 = encryptor2.encrypt("test")!
    XCTAssertNotEqual(value1, value2, "generates different hashed values")
    let prefix1 = value1.substringToIndex(advance(value1.startIndex, 7))
    let prefix2 = value2.substringToIndex(advance(value1.startIndex, 7))
    XCTAssertEqual(prefix1, "$2a$06$", "sets the prefix on the first hash")
    XCTAssertEqual(prefix2, "$2a$06$", "sets the prefix on the first hash")
  }
  
  func testEncryptGeneratesTheSameValueForSameSettingString() {
    let encryptor1 = BcryptHasher(setting: "$2a$08$f8ISxciVKO/xST.Rcj6iTO")
    let encryptor2 = BcryptHasher(setting: "$2a$08$f8ISxciVKO/xST.Rcj6iTO")
    let value1 = encryptor1.encrypt("12341234")!
    let value2 = encryptor2.encrypt("12341234")!
    XCTAssertEqual(value1, value2, "generates the same hashed value")
  }
  
  func testEncryptGeneratesTheSameValueForSameEncryptor() {
    let encryptor = BcryptHasher()
    let value1 = encryptor.encrypt("test")!
    let value2 = encryptor.encrypt("test")!
    XCTAssertEqual(value1, value2, "generates the same hashed value")
  }
  
  func testEncryptorCanRecognizeMatchingValues() {
    let value = BcryptHasher().encrypt("test1")!
    XCTAssertTrue(BcryptHasher.isMatch("test1", encryptedHash: value), "accepts correct value")
    XCTAssertFalse(BcryptHasher.isMatch("test2", encryptedHash: value), "rejects incorrect value")
  }
}
