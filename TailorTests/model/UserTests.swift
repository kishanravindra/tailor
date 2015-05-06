import XCTest
import Tailor
import TailorTesting

class UserTests: TailorTestCase {
  var user : User!
  
  override func setUp() {
    super.setUp()
    user = saveRecord(User(emailAddress: "test@test.com", password: "Monkey"))
  }
  
  //MARK: - Sign Up
  
  func testInitializationSetsEmailAddress() {
    assert(user.emailAddress, equals: "test@test.com", message: "sets email address")
  }
  
  func testInitializationSetsEncryptedPassword() {
    XCTAssertTrue(PasswordHasher.isMatch("Monkey", encryptedHash: user.encryptedPassword), "sets encrypted password")
  }
  
  //MARK: - Authentication
  
  func testHasPasswordIsTrueForMatchingPassword() {
    XCTAssertTrue(user.hasPassword("Monkey"), "approves correct password")
  }
  
  func testHasPasswordIsFalseForNonMatchingPassword() {
    XCTAssertFalse(user.hasPassword("M0nkey"), "rejects incorrect password")
  }
  
  func testAuthenticateReturnsUserWithMatchingEmailAndPassword() {
    let result = User.authenticate("test@test.com", password: "Monkey")
    XCTAssertNotNil(result, "returns a result")
    if result != nil {
      assert(user, equals: result!, message: "returns the matching user")
    }
  }
  
  func testAuthenticateReturnsNilWithInvalidEmailAddress() {
    let result = User.authenticate("test2@test.com", password: "Monkey")
    XCTAssertNil(result, "returns nil")
  }
  
  func testAuthenticateReturnsNilWithIncorrectPassword() {
    let result = User.authenticate("test@test.com", password: "M0nkey")
    XCTAssertNil(result, "returns nil")
  }
}
