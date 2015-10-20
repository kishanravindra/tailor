/**
  This class provides a Swift wrapper for hashing a password with SHA-512.
  */
public struct ShaPasswordHasher: PasswordHasherType {
  /**
    The salt that we are applying to the password.
    */
  public let salt: NSData
  
  /**
    This method creates a password hasher with a predefined salt.
  
    You must only provide a salt when comparing a password to an existing
    password hash. If you are hashing a new password, you must provide nil as
    the salt, which will cause this to generate a new random salt.
  
    This has been deprecated in favor of the versions that take
    
    - parameter salt:   The binary salt.
    */
  @available(*, deprecated, message="Use a non-optional salt, or omit the parameter")
  public init(salt: NSData?) {
    if let salt = salt {
      self.init(salt: salt)
    }
    else {
      self.init()
    }
  }
  
  /**
    This initializer creates a new password hasher with a pre-defined salt.
    
    You must only use this initializer when comparing a plaintext password
    against an existing salt or running tests. When you are hashing a new
    plaintext password, you must use the initializer that takes no parameters.
  
    - parameter salt:   The salt to add to the passwords when salting them.
    */
  public init(salt: NSData) {
    self.salt = salt
  }
  
  /**
    This initializer creates a password hasher with a random salt.
    */
  public init() { self.init(salt: ShaPasswordHasher.generateSalt()) }
  
  /**
    This method encrypts a string with this encryptor's settings.
    
    - parameter input:  The text to encrypt.
    - returns:          The encrypted hash, including the salt.
    */
  public func encrypt(input: String) -> String {
    let encodedSalt = salt.base64EncodedStringWithOptions([])
    let saltedInput = encodedSalt + input
    let inputBytes = NSData(bytes: saltedInput.utf8)
    let hashBytes = [UInt8](count: 64, repeatedValue: 0)
    CC_SHA512(inputBytes.bytes, UInt32(inputBytes.length), UnsafeMutablePointer<UInt8>(hashBytes))
    
    let encodedHash = NSData(bytes: hashBytes).base64EncodedStringWithOptions([])
    let countString = NSString(format: "%02i", encodedSalt.characters.count) as String
    return countString + encodedSalt + encodedHash
  }
  /**
    This method determines if a string is a match for an encrypted hash.
  
    This has been deprecated in favor of `isMatch(_:encryptedPassword:)`.
    
    - parameter input:            The input to check
    - parameter encryptedHash:    The hash to compare it against
    - returns:                    Whether the encrypted hash is a hash of the
                                  given input.
    */
  @available(*, deprecated, message="This has been deprecated in favor of the version with an encryptedPassword parameter")
  public static func isMatch(input: String, encryptedHash: String) -> Bool {
    return self.isMatch(input, encryptedPassword: encryptedHash)
  }
  
  /**
    This method gets the salt from an existing password hash.
  
    If the provided password hash does not have a valid salt, this must return
    nil.

    - parameter encryptedPassword:    The password hash.
    - returns:                        The salt from that hash.
    */
  public static func extractSalt(encryptedPassword: String) -> NSData? {
    let saltLength = Int(encryptedPassword.substringToIndex(encryptedPassword.startIndex.advancedBy(2))) ?? 0
    let encodedSalt = encryptedPassword.substringWithRange(Range(start: encryptedPassword.startIndex.advancedBy(2), end: encryptedPassword.startIndex.advancedBy(2 + saltLength)))
    let salt = NSData(base64EncodedString: encodedSalt, options: [])
    return salt
  }
}

@available(*, deprecated, message="This has been renamed to ShaPasswordHasher")
public typealias PasswordHasher = ShaPasswordHasher