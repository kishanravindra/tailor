import XCTest
import Tailor
import TailorTesting

@available(*, deprecated) class UserTests: TailorTestCase {
  var user : User!
  
  override func setUp() {
    super.setUp()
    user = User(emailAddress: "test@test.com", password: "Monkey").save()
  }
  
  //MARK: - Sign Up
  
  func testInitializationSetsEmailAddress() {
    assert(user.emailAddress, equals: "test@test.com", message: "sets email address")
  }
  
  func testInitializationSetsEncryptedPassword() {
    XCTAssertTrue(PasswordHasher.isMatch("Monkey", encryptedHash: user.encryptedPassword), "sets encrypted password")
  }
  
  func testInitializationWithValidDatabaseRowSetsFields() {
    let user = try! User(databaseRow: DatabaseRow(data: [
      "email_address": "test@test.com".databaseValue,
      "encrypted_password": "12345".databaseValue,
      "id": 1.databaseValue
      ]))
    assert(user.emailAddress, equals: "test@test.com")
    assert(user.encryptedPassword, equals: "12345")
    assert(user.id, equals: 1)
  }
  
  func testInitializationWithNoEmailAddressThrowsException() {
    do {
      _ = try User(databaseRow: DatabaseRow(data: [
        "encrypted_password": "12345".databaseValue,
        "id": 1.databaseValue
        ]))
      assert(false, message: "should throw an exception")
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "email_address")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testInitializationWithNoPasswordThrowsException() {
    do {
      _ = try User(databaseRow: DatabaseRow(data: [
        "email_address": "test@test.com".databaseValue,
        "id": 1.databaseValue
        ]))
      assert(false, message: "should throw an exception")
    }
    catch let DatabaseError.MissingField(name) {
      assert(name, equals: "encrypted_password")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testInitializationWithNoIdDoesNotThrowException() {
    do {
      let user = try User(databaseRow: DatabaseRow(data: [
        "email_address": "test@test.com".databaseValue,
        "encrypted_password": "12345".databaseValue
        ]))
      assert(isNil: user.id)
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  //MARK: - Authentication
  
  func testHasPasswordIsTrueForMatchingPassword() {
    XCTAssertTrue(user.hasPassword("Monkey"), "approves correct password")
  }
  
  func testHasPasswordIsFalseForNonMatchingPassword() {
    XCTAssertFalse(user.hasPassword("M0nkey"), "rejects incorrect password")
  }
  
  func testAuthenticateReturnsUserWithMatchingEmailAndPassword() {
    let result = rescue(try User.authenticate("test@test.com", password: "Monkey")) as? User
    XCTAssertNotNil(result, "returns a result")
    if result != nil {
      assert(user, equals: result!, message: "returns the matching user")
    }
  }
  
  func testAuthenticateReturnsNilWithInvalidEmailAddress() {
    let result = rescue(try User.authenticate("test2@test.com", password: "Monkey")) as? User
    XCTAssertNil(result, "returns nil")
  }
  
  func testAuthenticateReturnsNilWithIncorrectPassword() {
    let result = rescue(try User.authenticate("test@test.com", password: "M0nkey")) as? User
    XCTAssertNil(result, "returns nil")
  }
}
