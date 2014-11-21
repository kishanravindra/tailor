import Foundation

/**
  This class provides a model class for user accounts.

  It provides encryption of passwords, validation of accounts, and is integrated
  into the session management.
  */
public class User : Record {
  //MARK: - Structure
  
  /** The user's email address. */
  public dynamic var emailAddress: String!
  
  /** The user's password, encrypted with bcrypt. */
  public dynamic var encryptedPassword: String!
  
  public override class func persistedProperties() -> [String] { return ["emailAddress", "encryptedPassword"] }
  
  //MARK: Sign-Up
  
  /**
    This method creates a record for a new user account.

    :param: emailAddress  The new user's email address

    :param: password      The new user's password. This will not be stored on
                          the record; it will be encrypted immediately and
                          stored in the encryptedPassword.
    */
  public convenience init(emailAddress: String, password: String) {
    self.init()
    self.emailAddress = emailAddress
    self.encryptedPassword = BlowfishEncryptor().encrypt(password)
  }
  
  //MARK: Authentication
  
  /**
    This method determines if a password is correct for this user.

    :param: password    The password to check.
    :returns:           Whether the password is correct.
    */
  public func hasPassword(password: String) -> Bool {
    return BlowfishEncryptor.isMatch(password, encryptedHash: self.encryptedPassword)
  }
  
  /**
    This method looks up a user by email address and password.

    If the email address does not belong to any user, or the password is
    incorrect, this will return nil.

    :returns: The user
    */
  public class func authenticate(emailAddress: String, password: String) -> User? {
    let users = Query<User>().filter(["emailAddress": emailAddress]).all()
    
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