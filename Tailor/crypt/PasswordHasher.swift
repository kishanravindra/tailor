import Foundation

/**
  This class provides a Swift wrapper for hashing a string.
  */
public class PasswordHasher {
  /**
    The salt that we are applying to the password.
    */
  private let salt: NSData
  
  /**
    This method creates a password hasher.

    :param: salt
      The binary salt. If this is omitted, this will generate a random salt,
      which is generally preferable if you want to encrypt plaintext.
    */
  public init(salt: NSData? = nil) {
    if salt == nil {
      var saltBytes = [UInt8](count: 16, repeatedValue: 0)
      SecRandomCopyBytes(kSecRandomDefault, saltBytes.count, &saltBytes)
      self.salt = NSData(bytes: saltBytes)
    }
    else {
      self.salt = salt!
    }
  }
  
  /**
    This method encrypts a string with this encryptor's settings.

    :param: input
      The text to encrypt.

    :returns:
      The encrypted hash with the salt.
    */
  public func encrypt(input: String) -> String {
    let encodedSalt = salt.base64EncodedStringWithOptions(nil)
    let saltedInput = encodedSalt + input
    var inputBytes = saltedInput.cStringUsingEncoding(NSUTF8StringEncoding) ?? []
    
    var hashBytes = [UInt8](count: 64, repeatedValue: 0)
    CC_SHA512(UnsafePointer<Void>(inputBytes), UInt32(inputBytes.count), UnsafeMutablePointer<UInt8>(hashBytes))
    
    let encodedHash = NSData(bytes: hashBytes).base64EncodedStringWithOptions(nil)
    let countString = NSString(format: "%02i", count(encodedSalt)) as String
    return countString + encodedSalt + encodedHash
  }
  /**
    This method determines if a string is a match for an encrypted hash.
  
    :param: input
      The input to check
  
    :param: encryptedHash
      The hash to compare it against
  
    :returns:
      Whether the encrypted hash is a hash of the given input.
    */
  public class func isMatch(input: String, encryptedHash: String) -> Bool {
    let saltLength = encryptedHash.substringToIndex(advance(encryptedHash.startIndex, 2)).toInt() ?? 0
    let encodedSalt = encryptedHash.substringWithRange(Range(start: advance(encryptedHash.startIndex, 2), end: advance(encryptedHash.startIndex, 2 + saltLength)))
    let salt = NSData(base64EncodedString: encodedSalt, options: nil)
    let hasher = PasswordHasher(salt: salt)
    return hasher.encrypt(input) == encryptedHash
  }
}