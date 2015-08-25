import Foundation

/**
  This class provides a Swift wrapper for hashing a string.
  */
public struct PasswordHasher {
  /**
    The salt that we are applying to the password.
    */
  private let salt: NSData
  
  /**
    This method creates a password hasher.

    - parameter salt:   The binary salt. If this is omitted, this will generate a
                        random salt, which is generally preferable if you want
                        to encrypt plaintext.
    */
  public init(salt: NSData? = nil) {
    if let salt = salt {
      self.salt = salt
    }
    else {
      var saltBytes = [UInt8](count: 16, repeatedValue: 0)
      SecRandomCopyBytes(kSecRandomDefault, saltBytes.count, &saltBytes)
      self.salt = NSData(bytes: saltBytes)
    }
  }
  
  /**
    This method encrypts a string with this encryptor's settings.

    - parameter input:  The text to encrypt.
    - returns:          The encrypted hash with the salt.
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
  
    - parameter input:            The input to check
    - parameter encryptedHash:    The hash to compare it against
    - returns:                    Whether the encrypted hash is a hash of the
                                  given input.
    */
  public static func isMatch(input: String, encryptedHash: String) -> Bool {
    let saltLength = Int(encryptedHash.substringToIndex(encryptedHash.startIndex.advancedBy(2))) ?? 0
    let encodedSalt = encryptedHash.substringWithRange(Range(start: encryptedHash.startIndex.advancedBy(2), end: encryptedHash.startIndex.advancedBy(2 + saltLength)))
    let salt = NSData(base64EncodedString: encodedSalt, options: [])
    let hasher = PasswordHasher(salt: salt)
    return hasher.encrypt(input) == encryptedHash
  }
}