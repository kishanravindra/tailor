import XCTest
import Tailor
import TailorTesting
import Foundation

struct TestPasswordHasherType: XCTestCase, TailorTestable {
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testGenerateSaltGenerates16Digits", testGenerateSaltGenerates16Digits),
    ("testIsMatchWithMatchingStringsReturnsTrue", testIsMatchWithMatchingStringsReturnsTrue),
    ("testIsMatchWithNonMatchingStringsReturnsFalse", testIsMatchWithNonMatchingStringsReturnsFalse),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  struct BadPasswordHasher: PasswordHasherType {
    let salt: NSData
    
    func encrypt(plainPassword: String) -> String {
      let encodedSalt = salt.base64EncodedStringWithOptions([])
      let saltedInput = encodedSalt + plainPassword
      return saltedInput
    }
    
    init(salt: NSData) { self.salt = salt }
    init() { self.init(salt: BadPasswordHasher.generateSalt()) }
    
    static func extractSalt(encryptedPassword: String) -> NSData? {
      let encodedSalt = encryptedPassword.substringWithRange(Range(start: encryptedPassword.startIndex, end: encryptedPassword.startIndex.advancedBy(24)))
      let salt = NSData(base64EncodedString: encodedSalt, options: [])
      return salt
    }
  }
  
  func testGenerateSaltGenerates16Digits() {
    let salt = BadPasswordHasher.generateSalt()
    assert(salt.length, equals: 16)
  }
  
  func testIsMatchWithMatchingStringsReturnsTrue() {
    let salt = BadPasswordHasher.generateSalt()
    let encodedSalt = salt.base64EncodedStringWithOptions([])
    let string1 = encodedSalt + "hello"
    NSLog("String 1 is %@", string1)
    assert(BadPasswordHasher.isMatch("hello", encryptedPassword: string1))
  }
  
  func testIsMatchWithNonMatchingStringsReturnsFalse() {
    let salt = BadPasswordHasher.generateSalt()
    let encodedSalt = salt.base64EncodedStringWithOptions([])
    let string1 = encodedSalt + "hell"
    assert(!BadPasswordHasher.isMatch("hello", encryptedPassword: string1))
  }
}
