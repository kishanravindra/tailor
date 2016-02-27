import Tailor
import TailorTesting
import XCTest

final class TestUserType: XCTestCase, TailorTestable {
  struct TrackableUser: TrackableUserType {
    let id: UInt
    var emailAddress: String = ""
    var encryptedPassword: String = ""
    var lastSignInIp: String = ""
    var lastSignInTime: Timestamp = Timestamp(epochSeconds: 0)
    
    init() {
      id = 0
    }
    
    init(deserialize values: SerializableValue) throws {
      self.id = try values.read("id")
      self.emailAddress = try values.read("email_address")
      self.encryptedPassword = try values.read("encrypted_password")
      self.lastSignInIp = (try values.read("last_sign_in_ip")) ?? ""
      self.lastSignInTime = (try values.read("last_sign_in_time") as Timestamp?) ?? Timestamp(epochSeconds: 0)
    }
    
    func valuesToPersist() -> [String : SerializationEncodable?] {
      return [
        "email_address": emailAddress,
        "encrypted_password": encryptedPassword,
        "last_sign_in_ip": lastSignInIp,
        "last_sign_in_time": lastSignInTime
      ]
    }
    
    static let tableName = "users"
  }
  
  struct LockableUser: LockableUserType {
    let id: UInt
    var emailAddress: String = ""
    var encryptedPassword: String = ""
    var failedLogins: Int = 0
    
    init() {
      id = 0
    }
    
    init(deserialize values: SerializableValue) throws {
      self.id = try values.read("id")
      self.emailAddress = try values.read("email_address")
      self.encryptedPassword = try values.read("encrypted_password")
      self.failedLogins = (try values.read("failed_logins")) ?? 0
    }
    
    func valuesToPersist() -> [String : SerializationEncodable?] {
      return [
        "email_address": emailAddress,
        "encrypted_password": encryptedPassword,
        "failed_logins": failedLogins
      ]
    }
    
    static let tableName = "users"
  }
  
  var user = TestUser()
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testSettingPasswordEncryptsPassword", testSettingPasswordEncryptsPassword),
    ("testHasPasswordIsTrueForMatchingPassword", testHasPasswordIsTrueForMatchingPassword),
    ("testHasPasswordIsFalseForNonMatchingPassword", testHasPasswordIsFalseForNonMatchingPassword),
    ("testAuthenticateReturnsUserWithMatchingEmailAndPassword", testAuthenticateReturnsUserWithMatchingEmailAndPassword),
    ("testAuthenticateWithInvalidEmailAddressThrowsError", testAuthenticateWithInvalidEmailAddressThrowsError),
    ("testAuthenticateWithIncorrectPasswordThrowsError", testAuthenticateWithIncorrectPasswordThrowsError),
    ("testAuthenticateWithLockableUserWithCorrectPasswordResetsLockCount", testAuthenticateWithLockableUserWithCorrectPasswordResetsLockCount),
    ("testAuthenticateWithLockableUserWithIncorrectPasswordIncrementsLockCount", testAuthenticateWithLockableUserWithIncorrectPasswordIncrementsLockCount),
    ("testAuthenticateWithLockedOutUserThrowsError", testAuthenticateWithLockedOutUserThrowsError),
    ("testLockedOutIsTrueWithFailedLoginCountAtThreshold", testLockedOutIsTrueWithFailedLoginCountAtThreshold),
    ("testLockedOutIsFalseithFailedLoginCountBelowThreshold", testLockedOutIsFalseithFailedLoginCountBelowThreshold),
  ]}
  
  func setUp() {
    setUpTestCase()
    user = TestUser()
    user.emailAddress = "test@test.com"
    user.password = "Monkey"
    user = user.save()!
  }
  
  func testSettingPasswordEncryptsPassword() {
    user.password = "TestUser!"
    assert(ShaPasswordHasher.isMatch("TestUser!", encryptedPassword: user.encryptedPassword), message: "stores an encrypted version of the password")
    assert(user.password, equals: user.encryptedPassword)
  }
  
  func testHasPasswordIsTrueForMatchingPassword() {
    assert(user.hasPassword("Monkey"), message: "approves correct password")
  }
  
  func testHasPasswordIsFalseForNonMatchingPassword() {
    assert(!user.hasPassword("M0nkey"), message: "rejects incorrect password")
  }
  
  func testAuthenticateReturnsUserWithMatchingEmailAndPassword() {
    do {
      let result = try TestUser.authenticate("test@test.com", password: "Monkey")
      assert(result.id, equals: user.id, message: "returns the matching user")
    }
    catch {
      assert(false, message: "threw unexpected error")
    }
  }
  
  func testAuthenticateWithInvalidEmailAddressThrowsError() {
    do {
      _ = try TestUser.authenticate("test2@test.com", password: "Monkey")
      assert(false, message: "should throw exception")
    }
    catch UserLoginError.WrongEmailAddress {
      assert(true, message: "threw expected exception")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testAuthenticateWithIncorrectPasswordThrowsError() {
    do {
      _ = try TestUser.authenticate("test@test.com", password: "M0nkey")
      assert(false, message: "should throw exception")
    }
    catch UserLoginError.WrongPassword {
      assert(true, message: "threw expected exception")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
  }
  
  func testAuthenticateWithLockableUserWithCorrectPasswordResetsLockCount() {
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("ALTER TABLE `users` ADD COLUMN `failed_logins` int")
    var user = Query<LockableUser>().first()!
    user.failedLogins = 2
    user.save()
    do {
      _ = try LockableUser.authenticate("test@test.com", password: "Monkey")
    }
    catch {
    }
    assert(Query<LockableUser>().first()?.failedLogins, equals: 0)
    CreateTestDatabaseAlteration.run()
  }
  
  func testAuthenticateWithLockableUserWithIncorrectPasswordIncrementsLockCount() {
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("ALTER TABLE `users` ADD COLUMN `failed_logins` int")
    do {
      _ = try LockableUser.authenticate("test@test.com", password: "M0nkey")
    }
    catch {
    }
    assert(Query<LockableUser>().first()?.failedLogins, equals: 1)
    CreateTestDatabaseAlteration.run()
  }
  
  func testAuthenticateWithLockedOutUserThrowsError() {
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("ALTER TABLE `users` ADD COLUMN `failed_logins` int")
    do {
      var user = Query<LockableUser>().first()!
      user.failedLogins = 5
      user.save()
      _ = try LockableUser.authenticate("test@test.com", password: "M0nkey")
      assert(false, message: "should throw exception")
    }
    catch UserLoginError.LockedOut {
      assert(true, message: "threw expected exception")
    }
    catch {
      assert(false, message: "threw unexpected exception")
    }
    CreateTestDatabaseAlteration.run()
  }
  
  func testLockedOutIsTrueWithFailedLoginCountAtThreshold() {
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("ALTER TABLE `users` ADD COLUMN `failed_logins` int")
    var user = LockableUser()
    user.failedLogins = 5
    assert(user.lockedOut)
    CreateTestDatabaseAlteration.run()
  }
  
  func testLockedOutIsFalseithFailedLoginCountBelowThreshold() {
    let connection = Application.sharedDatabaseConnection()
    connection.executeQuery("ALTER TABLE `users` ADD COLUMN `failed_logins` int")
    var user = LockableUser()
    user.failedLogins = 4
    assert(!user.lockedOut)
    CreateTestDatabaseAlteration.run()
  }
}