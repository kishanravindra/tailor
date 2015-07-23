import Foundation

/**
  This class provides a high-level interface for doing AES encryption.
  */
public final class AesEncryptor {
  /** The low-level key for the encryption. */
  private let key: SecKey?
  
  //MARK: - Encodings
  
  /**
    This method converts a byte into a hex string.
  
    - parameter byte:     The byte to encode
    - parameter pad:      Whether we should force this to be a two-character
                          string.
    - returns:            The encoded string.
    */
  public class func getHexString(byte: UInt8, pad: Bool = true) -> String {
    if pad {
      return getHexString(byte / 16, pad: false) + getHexString(byte % 16, pad: false)
    }
    switch(byte) {
    case let digit where digit < 10:
      return String(digit)
    case 10: return "A"
    case 11: return "B"
    case 12: return "C"
    case 13: return "D"
    case 14: return "E"
    case 15: return "F"
    default:
      return getHexString(byte / 16, pad: false) + getHexString(byte % 16, pad: false)
    }
  }
  
  /**
    This method interprets a string as a hex byte.

    If it's a one character string, it will interpret it as a single hex digit.
  
    If it's a two character string, it will interpret is as a single byte, and
    use this method to get the hex digits for each character and combine them.
  
    If the string is not a valid hex byte, this will return nil.

    - parameter byte:     The string
    - returns:            The hex byte.
    */
  public class func getHex(byte: String) -> UInt8? {
    switch(byte.characters.count) {
    case 1:
      switch(byte) {
      case "A": return 10
      case "B": return 11
      case "C": return 12
      case "D": return 13
      case "E": return 14
      case "F": return 15
      default:
        if let int = Int(byte) {
          return UInt8(int)
        }
        else {
          return nil
        }
      }
    case 2:
      guard let top = self.getHex(String(byte[byte.startIndex])),
        let bottom = self.getHex(String(byte[advance(byte.startIndex, 1)]))
        else {
          return nil
      }

      return top * 16 + bottom
    default:
      return nil
    }
  }
  
  //MARK: - Creation
  
  /**
    This method creates a new AES encryptor/decryptor.

    - parameter key:    A string with the hexadecimal encoding of the
                        encryption key. The key must be at least 64 characters.
                        If it is fewer than 64 characters, this return nil.
  
    */
  public init?(key hexKey: String) {
    let keyData = NSMutableData()
    if hexKey.characters.count < 64 {
      self.key = nil
      return nil
    }
    for indexOfByte in (0..<hexKey.characters.count/2) {
      let range = Range(start: advance(hexKey.startIndex, indexOfByte), end: advance(hexKey.startIndex, indexOfByte + 2))
      if var byte = AesEncryptor.getHex(hexKey.substringWithRange(range)) {
        keyData.appendBytes(&byte, length: 1)
      }
    }
    
    let keyParams = [
      kSecAttrKeyType as NSString: kSecAttrKeyTypeAES as NSString,
      kSecAttrKeySizeInBits as NSString: NSNumber(int: 256)
    ]
    
    self.key = SecKeyCreateFromData(keyParams, keyData, nil)
  }
  
  //MARK: - Encryption

  /**
    This method encrypts data with our key.

    - parameter data:     The plaintext.
    - returns:            The encrypted data.
    */
  public func encrypt(data: NSData) -> NSData {
    guard let key = self.key else { return NSData() }
    let encryptor = SecEncryptTransformCreate(key, nil)
    SecTransformSetAttribute(encryptor, kSecTransformInputAttributeName, data, nil)
    return (SecTransformExecute(encryptor, nil) as? NSData) ?? NSData()
  }
  
  /**
    This method decrypts data with our key.

    - parameter data:   The encrypted data.
    - returns:          The plaintext.
    */
  public func decrypt(data: NSData) -> NSData {
    guard let key = self.key else { return NSData() }
    let decryptor = SecDecryptTransformCreate(key, nil)
    SecTransformSetAttribute(decryptor, kSecTransformInputAttributeName, data, nil)
    return (SecTransformExecute(decryptor, nil) as? NSData) ?? NSData()
  }
  
  //MARK: - Key Generation
  
  /**
    This method generates an AES key.

    - returns:   The hexadecimal encoding of the key.
    */
  public class func generateKey() -> String {
    let keyParams = [
      kSecAttrKeyType as NSString: kSecAttrKeyTypeAES as NSString,
      kSecAttrKeySizeInBits as NSString: NSNumber(int: 256)
    ]
    guard let key = SecKeyGenerateSymmetric(keyParams, nil) else { return "" }
    var dataContainer: CFData? = nil
    SecItemExport(key, SecExternalFormat.FormatUnknown, SecItemImportExportFlags(), nil, &dataContainer)
    
    
    var keyString = ""
    
    if let container = dataContainer {
      let data = container as NSData
      var bytes = [UInt8](count: data.length, repeatedValue: 0)
      data.getBytes(&bytes, length: data.length)
      for byte in bytes {
        keyString += self.getHexString(byte)
      }
    }
    return keyString
  }
}