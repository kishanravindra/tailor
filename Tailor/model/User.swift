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

  This class has been deprecated in favor of the UserType protocol.
  */
@available(*, deprecated, message="Use the UserType protocol instead") public final class User : UserType, Equatable {
  //MARK: - Structure
  
  /** The primary key for the record. */
  public let id: Int?
  
  /** The user's email address. */
  public var emailAddress: String
  
  /** The user's password, encrypted with bcrypt. */
  public var encryptedPassword: String
  
  /** A query for fetching users. */
  static let query = Query<User>()
  
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
}