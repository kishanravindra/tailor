import Foundation

/**
  This class provides a high-level interface for doing AES encryption.
  */
public final class AesEncryptor {
  /** The low-level key for the encryption. */
  private let key: Unmanaged<SecKey>
  
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
      let top = self.getHex(String(byte[byte.startIndex]))
      let bottom = self.getHex(String(byte[advance(byte.startIndex, 1)]))
      if top != nil && bottom != nil {
        return top! * 16 + bottom!
      }
      else {
        return nil
      }
    default:
      return nil
    }
  }
  
  //MARK: - Creation
  
  /**
    This method creates a new AES encryptor/decryptor.

    - parameter key:    A string with the hexadecimal encoding of the
                        encryption key.
    */
  public init(key hexKey: String) {
    let keyData = NSMutableData()
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
  
  /**
    This method deinitializes the encryptor.

    This will release our hold on the underlying security transforms.
    */
  deinit {
    key.release()
  }
  
  //MARK: - Encryption

  /**
    This method encrypts data with our key.

    - parameter data:     The plaintext.
    - returns:            The encrypted data.
    */
  public func encrypt(data: NSData) -> NSData {
    let encryptor = SecEncryptTransformCreate(key.takeUnretainedValue(), nil)
    SecTransformSetAttribute(encryptor.takeUnretainedValue(), kSecTransformInputAttributeName, data, nil)
    return (SecTransformExecute(encryptor.takeUnretainedValue(), nil) as? NSData) ?? NSData()
  }
  
  /**
    This method decrypts data with our key.

    - parameter data:   The encrypted data.
    - returns:          The plaintext.
    */
  public func decrypt(data: NSData) -> NSData {
    let decryptor = SecDecryptTransformCreate(key.takeUnretainedValue(), nil)
    SecTransformSetAttribute(decryptor.takeUnretainedValue(), kSecTransformInputAttributeName, data, nil)
    return (SecTransformExecute(decryptor.takeUnretainedValue(), nil) as? NSData) ?? NSData()
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
    let key = SecKeyGenerateSymmetric(keyParams, nil)
    var dataContainer: Unmanaged<CFData>? = nil
    SecItemExport(key.takeUnretainedValue(), UInt32(kSecFormatUnknown), 0, nil, &dataContainer)
    
    
    var keyString = ""
    
    if dataContainer != nil {
      let data = dataContainer!.takeUnretainedValue() as NSData
      var bytes = [UInt8](count: data.length, repeatedValue: 0)
      data.getBytes(&bytes, length: data.length)
      for byte in bytes {
        keyString += self.getHexString(byte)
      }
      dataContainer!.release()
    }
    key.release()
    return keyString
  }
}