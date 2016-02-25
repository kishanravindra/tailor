import Foundation

/**
  This protocol describes a user account.

  A user account must store an email address and a salted password in a table.
  The name of the column holding email addresses is specified by the
  `emailAddressColumn` field. The name of the column holding passwords must be
  `encrypted_password`.
  */
public protocol UserType: Persistable {
  /** The user's email address. */
  var emailAddress: String { get }
  
  /** The user's password, encrypted with an AES encryptor by default. */
  var encryptedPassword: String { get set }
  
  /**
    This method determines if a password is correct for this user.
  
    The default implementation takes a hash of the suggested password,
    based on the encryption settings in the current encrypted password, and see
    if the hashes match.
    
    - parameter password:     The password to check.
    - returns:                Whether the password is correct.
    */
  func hasPassword(password: String) -> Bool
  
  /**
    The type of hasher that we should use to encrypt this user's passwords.

    The default is to use a `ShaPasswordHasher`.
    */
  var passwordHasherType: PasswordHasherType.Type { get }
  
  /**
    The name of the column that we use to store email addresses.

    The default is to use `email_address`, but you can override this if it is
    more to your tastes to call this column `email` or something else.
    */
  static var emailAddressColumn: String { get }
}

extension UserType {
  public var passwordHasherType: PasswordHasherType.Type { return ShaPasswordHasher.self }
  public static var emailAddressColumn: String { return "email_address" }
  
  /**
    This field allows setting the encrypted password by providing the
    unencrypted value of the new password.
  
    This will encrypt the value with the specified password hasher.
  
    After setting a password, the getter will return the encrypted password.
    */
  public var password: String {
    get {
      return encryptedPassword
    }
    set {
      encryptedPassword = self.passwordHasherType.init().encrypt(newValue)
    }
  }
  /**
    This method determines if a password is correct for this user.
  
    This will hash the proposed password with our password
    
    - parameter password:     The password to check.
    - returns:                Whether the password is correct.
    */
  public func hasPassword(password: String) -> Bool {
    return self.passwordHasherType.isMatch(password, encryptedPassword: self.encryptedPassword)
  }
  
  /**
    This method looks up a user by email address and password.
    
    If the email address does not belong to any user, or the password is
    incorrect, or the user is locked out of their account, this will throw an
    error from `UserLoginError`.
    
    - returns: The user
    */
  public static func authenticate(emailAddress: String, password: String) throws -> UserType {
    let users = query.filter([emailAddressColumn: emailAddress]).allRecords().flatMap { $0 as? UserType }
  
    if users.isEmpty {
      throw UserLoginError.WrongEmailAddress
    }
    
    let user = users[0]
    var lockableUser = user as? LockableUserType
    if lockableUser?.lockedOut ?? false {
      throw UserLoginError.LockedOut
    }
    if user.hasPassword(password) {
      lockableUser?.failedLogins = 0
      lockableUser?.save()
      return user
    }
    else {
      lockableUser?.failedLogins += 1
      lockableUser?.save()
      throw UserLoginError.WrongPassword
    }
  }
}

/**
  This type provides the errors that can be thrown when signing a user in.
  */
public enum UserLoginError: ErrorType {
  /** The email address provided does not match any user account. */
  case WrongEmailAddress
  
  /** The password provided is not the user's password. */
  case WrongPassword
  
  /** The user has exceeded the limit of failed logins and is locked out. */
  case LockedOut
}

/**
  This type describes a user that can have their logins tracked on their user
  account.

  If your user type conforms to this protocol, the fields will be automatically
  set when they log in.
  */
public protocol TrackableUserType: UserType {
  /** The IP address that the user last signed in from. */
  var lastSignInIp: String { get set }
  
  /** The time when the user last signed in. */
  var lastSignInTime: Timestamp { get set }
}

/**
  This type describes a user that can be locked out of their accounts after
  multiple failed logins.
  */
public protocol LockableUserType: UserType {
  /**
    The number of times that someone has tried to log into the account with the
    wrong password.

    This will be automatically incremented in the `authenticate` method when
    they try to log in, and will be reset to 0 when they log in successfully.

    If this count reaches the limit set in
    `Application.configuration.failedLoginLimit`, they will not be able to log
    in with their correct password until the count is reset through some other
    method.
    */
  var failedLogins: Int { get set }
}

extension LockableUserType {
  /**
    This method determines if the user is locked out, because their failed login
    count has hit the limit.
    */
  public var lockedOut: Bool {
    return failedLogins >= Application.configuration.failedLoginLimit
  }
}