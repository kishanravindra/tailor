import Foundation
import COpenSSL

/**
  This protocol describes a system for hashing passwords.

  This makes the assumption that you are using a per-password salt that is
  encoded into the encrypted hash.
  */
public protocol PasswordHasherType {
  /**
    This initializer creates a new password hasher with a randomized salt.
  
    The best practice is to call the `init(salt:)` initializer with the result
    of `generateSalt`, but we cannot currently provide a default implementation
    that does that.
    */
  init()
  
  /**
    This initializer creates a new password hasher with a pre-defined salt.

    You must only use this initializer when comparing a plaintext password
    against an existing salt or running tests. When you are hashing a new 
    plaintext password, you must use the initializer that takes no parameters.

    - parameter salt:   The salt to add to the passwords when salting them.
    */
  init(salt: NSData)
  
  /**
    This method encrypts a plaintext password with this hasher and salt.
  
    This must have the following properties:
  
    - Hashing a password twice with the same salt must produce the same result
    - Hashing a password twice with two different salts must produce a different
      result
    - Hashing two different passwords with the same salt must produce different
      results
    - The hash must include the salt in such a way that it can be extracted by
      the `extractSalt` method
    - It must be difficult to get the plaintext password if one only knows the
      hash
  
    The second and third properties may not be possible in all cases because of
    hash collisions, but such collisions must be made extremely rare.

    - parameter plainPassword:    The password to hash
    - returns:                    The hash of the password.
    */
  func encrypt(plainPassword: String) -> String
  
  /**
    This method gets the salt from a password hash.
  
    If the hash does not have a valid salt encoded in it, this must return nil.

    - parameter encryptedPassword:    The password to encrypt.
    - returns:                        The salt.
    */
  static func extractSalt(encryptedPassword: String) -> NSData?
  
  /**
    This method determines if a plaintext password matches an ecnrypted
    password.

    The default implementation will extract the salt from the encrypted
    password, use it to hash the plaintext password, and determine if the
    resulting hashes match.
  
    - parameter plainPassword:      The plaintext password to check.
    - parameter encryptedPassword:  The hash to check it against.
    - returns:                      Whether the plain password matches the one
                                    that was used to generate the hash.
    */
  static func isMatch(plainPassword: String, encryptedPassword: String) -> Bool
  
  /**
    This method gets a random salt for a new password hasher.
  
    The default implementation generates 16 random bytes.
    */
  static func generateSalt() -> NSData
}

extension PasswordHasherType {
  public static func hashData(data: NSData, digest: UnsafePointer<EVP_MD>) -> NSData {
    var context = EVP_MD_CTX()
    let digestSize = Int(EVP_MD_size(digest))
    EVP_MD_CTX_init(&context)
    EVP_DigestInit_ex(&context, digest, nil)
    EVP_DigestUpdate(&context, data.bytes, data.length)
    let buffer = UnsafeMutablePointer<UInt8>(calloc(sizeof(CChar), digestSize))
    var length = UInt32(0)
    EVP_DigestFinal_ex(&context, buffer, &length)
    EVP_MD_CTX_cleanup(&context)
    let result = NSData(bytes: buffer, length: Int(length))
    free(buffer)
    return result
  }

  public static func generateSalt() -> NSData {
    let saltBytes = RandomNumber.generateBytes(16)
    return NSData(bytes: saltBytes)
  }
  
  public static func isMatch(plainPassword: String, encryptedPassword: String) -> Bool {
    if let salt = self.extractSalt(encryptedPassword) {
      let reencryptedPassword = self.init(salt: salt).encrypt(plainPassword)
      return reencryptedPassword == encryptedPassword
    }
    else {
      return false
    }
  }
}

