import Foundation

/**
  This class provides a model class for user accounts.

  It provides encryption of passwords, validation of accounts, and is integrated
  into the session management.
  */
public class User : Persistable {
  //MARK: - Structure
  
  /** The primary key for the record. */
  public let id: Int?
  
  /** The user's email address. */
  public var emailAddress: String
  
  /** The user's password, encrypted with bcrypt. */
  public var encryptedPassword: String
  
  //MARK: Sign-Up
  /**
    This method creates a record for a new user account.

    :param: emailAddress  The new user's email address

    :param: password      The new user's password. This will not be stored on
                          the record; it will be encrypted immediately and
                          stored in the encryptedPassword.
    */
  public init(emailAddress: String, password: String) {
    self.emailAddress = emailAddress
    self.encryptedPassword = BcryptHasher().encrypt(password) ?? ""
    self.id = nil
  }
  
  public init(emailAddress: String, encryptedPassword: String, id: Int) {
    self.emailAddress = emailAddress
    self.encryptedPassword = encryptedPassword
    self.id = id
  }
  
  //MARK: Persistence
  
  /** The name of the table where the records are stored. */
  public class func tableName() -> String { return "users" }
  
  public required convenience init?(databaseRow: [String:DatabaseValue]) {
    if let emailAddress = databaseRow["email_address"]?.stringValue,
      let encryptedPassword = databaseRow["encrypted_password"]?.stringValue,
      let id = databaseRow["id"]?.intValue {
        self.init(emailAddress: emailAddress, encryptedPassword: encryptedPassword, id: id)
    }
    else {
      self.init(emailAddress: "", password: "")
      return nil
    }
  }
  
  public func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return [
      "email_address": self.emailAddress,
      "encrypted_password": self.encryptedPassword
    ]
  }
  
  //MARK: Authentication
  
  /**
    This method determines if a password is correct for this user.

    :param: password    The password to check.
    :returns:           Whether the password is correct.
    */
  public func hasPassword(password: String) -> Bool {
    return BcryptHasher.isMatch(password, encryptedHash: self.encryptedPassword)
  }
  
  /**
    This method looks up a user by email address and password.

    If the email address does not belong to any user, or the password is
    incorrect, this will return nil.

    :returns: The user
    */
  public class func authenticate(emailAddress: String, password: String) -> User? {
    let users = Query<User>().filter(["email_address": emailAddress]).all()
    
    if users.isEmpty {
      return nil
    }
    
    let user = users[0]
    if user.hasPassword(password) {
      return user
    }
    else {
      return nil
    }
  }
}