import Foundation

/**
  This protocol describes a user account.

  A user account must store an email address and a salted password in a table
  in columns called `email_address` and `encrypted_password`.
  */
public protocol UserType: Persistable {
  /** The user's email address. */
  var emailAddress: String { get }
  
  /** The user's password, encrypted with bcrypt. */
  var encryptedPassword: String { get set }
}

extension UserType {
  /**
    This field allows setting the encrypted password by providing the
    unencrypted value of the new password.
  
    After setting a password, the getter will return the encrypted password.
    */
  public var password: String {
    get {
      return encryptedPassword
    }
    set {
      encryptedPassword = PasswordHasher().encrypt(newValue)
    }
  }
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
  public static func authenticate(emailAddress: String, password: String) -> UserType? {
    let users = query.filter(["email_address": emailAddress]).allRecords().flatMap { $0 as? UserType }
    
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