import Foundation

/**
  This class provides a Swift wrapper for hashing a string with Bcrypt.
  */
public class BcryptHasher {
  /**
    The setting string for bcrypt.
  
    It contains an encoding of the bcrypt version, the number of rounds, and
    the salt, and will be the prefix for the resulting hash.
    */
  private let setting : String
  
  /**
    This method creates an encryptor with an already-formatted setting string.
  
    The setting string should have the format "$2a$07salt", where "a" is the
    bcrypt version, "7" is the base-2 logarithm of the number of rounds to
    perform, and "salt" is the salt.

    :param: setting
      The setting string for the encryption.
    */
  public init(setting: String) {
    self.setting = setting
  }
  
  /**
    This method creates an encryptor with options for bcrypt.

    :param: version
      The bcrypt version.

    :param: salt
      The binary salt. If this is omitted, this will generate a random salt,
      which is generally preferable if you want to encrypt plaintext.

    :param rounds
      The number of rounds of encryption to perform.
    */
  public convenience init(version: String = "a", salt: [UInt8]? = nil, rounds: Int = 6) {
    var sanitizedSalt : [UInt8]! = salt
    if salt == nil {
      sanitizedSalt = [UInt8](count: 16, repeatedValue: 0)
      SecRandomCopyBytes(kSecRandomDefault, UInt(sanitizedSalt.count), &sanitizedSalt!)
    }
    
    while sanitizedSalt.count < 16 { sanitizedSalt.append(0) }
    var setting = [Int8](count: 128, repeatedValue: 0)
    
    _crypt_gensalt_blowfish_rn(
      UnsafePointer<Int8>("$2".stringByAppendingString(version).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!.bytes),
      UInt(rounds),
      UnsafePointer<Int8>(sanitizedSalt),
      Int32(sanitizedSalt.count),
      &setting,
      Int32(setting.count)
    )
    
    let settingString = NSString(CString: &setting, encoding: NSUTF8StringEncoding) as! String
    self.init(setting: settingString)
  }
  
  /**
    This method encrypts a string with this encryptor's settings.

    :param: input
      The text to encrypt.

    :returns:
      The encrypted hash with the salt.
    */
  public func encrypt(input: String) -> String? {
    var output = [Int8](count: 128, repeatedValue: 0)
    
    let inputPointer : [CChar]! = input.cStringUsingEncoding(NSUTF8StringEncoding)
    let settingPointer : [CChar]! = self.setting.cStringUsingEncoding(NSUTF8StringEncoding)
    
    if inputPointer == nil || settingPointer == nil {
      return nil
    }
    
    _crypt_blowfish_rn(
      UnsafePointer<Int8>(inputPointer),
      UnsafePointer<Int8>(settingPointer),
      &output,
      Int32(output.count)
    )
    
    let result = NSString(CString: &output, encoding: NSUTF8StringEncoding)
    return result as? String
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
    let setting = encryptedHash.substringToIndex(advance(encryptedHash.startIndex, 29))
    let encryptedInput = BcryptHasher(setting: setting).encrypt(input)
    return encryptedInput != nil && encryptedInput! == encryptedHash
  }
}