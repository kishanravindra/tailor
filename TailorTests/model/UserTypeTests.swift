import Tailor
import TailorTesting

class UserTypeTests: TailorTestCase {
  var user = TestUser()
  override func setUp() {
    super.setUp()
    user = TestUser()
    user.emailAddress = "test@test.com"
    user.password = "Monkey"
    user = user.save()!
  }
  
  func testSettingPasswordEncryptsPassword() {
    user.password = "TestUser!"
    assert(PasswordHasher.isMatch("TestUser!", encryptedHash: user.encryptedPassword), message: "stores an encrypted version of the password")
    assert(user.password, equals: user.encryptedPassword)
  }
  
  func testHasPasswordIsTrueForMatchingPassword() {
    assert(user.hasPassword("Monkey"), message: "approves correct password")
  }
  
  func testHasPasswordIsFalseForNonMatchingPassword() {
    assert(!user.hasPassword("M0nkey"), message: "rejects incorrect password")
  }
  
  func testAuthenticateReturnsUserWithMatchingEmailAndPassword() {
    let result = TestUser.authenticate("test@test.com", password: "Monkey")
    assert(result?.id, equals: user.id!, message: "returns the matching user")
  }
  
  func testAuthenticateReturnsNilWithInvalidEmailAddress() {
    let result = TestUser.authenticate("test2@test.com", password: "Monkey")
    assert(isNil: result)
  }
  
  func testAuthenticateReturnsNilWithIncorrectPassword() {
    let result = TestUser.authenticate("test@test.com", password: "M0nkey")
    assert(isNil: result)
  }
}