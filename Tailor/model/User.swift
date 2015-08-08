import Foundation

/**
  This class provides a model class for user accounts.

  It provides encryption of passwords, validation of accounts, and is integrated
  into the session management.

  To use this class, you must have a table called users, which must contain
  columns for email_address and encrypted_password. Both of these columns must
  be string types.

  You can support a different table name or column layout by subclassing this
  class and overriding the methods in the Persistable protocol.
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

    - parameter emailAddress:   The new user's email address

    - parameter password:       The new user's password. This will not be stored
                                on the record; it will be encrypted immediately
                                and stored in the encryptedPassword.
    */
  public init(emailAddress: String, password: String) {
    self.emailAddress = emailAddress
    self.encryptedPassword = PasswordHasher().encrypt(password)
    self.id = nil
  }
  
  //MARK: Persistence
  
  /** The name of the table where the records are stored. */
  public class var tableName: String { return "users" }
  
  /**
    This method initializes a user from a row in the database.

    The row must have a column for email_address, encrypted_password, and id.
    If it does not, this will return nil.
  
    - parameter databaseRow:   The information from the database.
    */
  public required init(databaseRow: DatabaseRow) throws {
    do {
      self.emailAddress = try databaseRow.read("email_address")
      self.encryptedPassword = try databaseRow.read("encrypted_password")
      self.id = try databaseRow.read("id")
    }
    catch let e {
      self.emailAddress = ""
      self.encryptedPassword = ""
      self.id = nil
      throw e
    }
  }
  
  /**
    This method gets the columns that we persist for users.

    For this implementation, we persist the email_address and encrypted_password
    columns.
    */
  public func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return [
      "email_address": self.emailAddress,
      "encrypted_password": self.encryptedPassword
    ]
  }
  
  //MARK: Authentication
  
  /**
    This method determines if a password is correct for this user.

    - parameter password:     The password to check.
    - returns:                Whether the password is correct.
    */
  public func hasPassword(password: String) -> Bool {
    return PasswordHasher.isMatch(password, encryptedHash: self.encryptedPassword)
  }
  
  /**
    This method looks up a user by email address and password.

    If the email address does not belong to any user, or the password is
    incorrect, this will return nil.

    - returns: The user
    */
  public class func authenticate(emailAddress: String, password: String) -> User? {
    let users = Users.filter(["email_address": emailAddress]).all()
    
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

/** A query for fetching all users, which you can build other queries off of. */
public let Users = Query<User>()