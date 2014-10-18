import Foundation

/**
  This class provides a Swift wrapper for encrypting a string with Blowfish.
  */
public class BlowfishEncryptor {
  /**
    The setting string for Blowfish.
  
    It contains an encoding of the Blowfish version, the number of rounds, and
    the salt, and will be the prefix for the resulting hash.
    */
  private let blowfishSetting : String
  
  /**
    This method creates an encryptor with an already-formatted setting string.

    :param: blowfishSetting
      The setting string for the encryption.
    */
  public init(blowfishSetting: String) {
    self.blowfishSetting = blowfishSetting
  }
  
  /**
    This method creates an encryptor with options for Blowfish.

    :param: version
      The Blowfish version.

    :param: salt
      The binary salt

    :param rounds
      The number of rounds of encryption to perform.
    */
  public convenience init(version: String = "a", salt: [UInt8]? = nil, rounds: Int = 6) {
    var sanitizedSalt : [UInt8]! = salt
    if salt == nil {
      sanitizedSalt = [UInt8]()
      for byte in 0..<16 { sanitizedSalt.append(0) }
      SecRandomCopyBytes(kSecRandomDefault, UInt(sanitizedSalt.count), &sanitizedSalt!)
    }
    
    while sanitizedSalt.count < 16 { sanitizedSalt.append(0) }
    var setting = [Int8]()
    for byte in 0..<128 { setting.append(0) }
    
    _crypt_gensalt_blowfish_rn(
      UnsafePointer<Int8>("$2".stringByAppendingString(version).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!.bytes),
      UInt(rounds),
      UnsafePointer<Int8>(sanitizedSalt),
      Int32(sanitizedSalt.count),
      &setting,
      Int32(setting.count)
    )
    
    let settingString = NSString(CString: &setting, encoding: NSUTF8StringEncoding)!
    self.init(blowfishSetting: settingString)
  }
  
  /**
    This method encrypts a string with this encryptor's settings.

    :param: input
      The text to encrypt.

    :returns:
      The encrypted hash with the salt.
    */
  public func encrypt(input: String) -> String? {
    var output = [Int8]()
    for i in 0..<128 { output.append(0) }
    
    let inputData = input.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    let settingData = self.blowfishSetting.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    
    if inputData == nil || settingData == nil {
      return nil
    }
    
    _crypt_blowfish_rn(
      UnsafePointer<Int8>(inputData!.bytes),
      UnsafePointer<Int8>(settingData!.bytes),
      &output,
      Int32(output.count)
    )
    
    return NSString(CString: &output, encoding: NSUTF8StringEncoding)
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
    let encryptedInput = BlowfishEncryptor(blowfishSetting: setting).encrypt(input)
    return encryptedInput != nil && encryptedInput! == encryptedHash
  }
}