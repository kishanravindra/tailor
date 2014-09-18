import Foundation

/**
  This class provides a high-level interface for doing AES encryption.
  */
class AesEncryptor {
  /** The transform for encrypting data. */
  private let encryptor: Unmanaged<SecTransform>
  
  /** The transform for decrypting data. */
  private let decryptor: Unmanaged<SecTransform>
  
  //MARK: - Encodings
  
  /**
    This method converts a byte into a hex string.
  
    :param: byte    The byte to encode
    :param: pad     Whether we should force this to be a two-character string.
    :returns:       The encoded string.
    */
  class func getHexString(byte: UInt8, pad: Bool = true) -> String {
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

    :param: byte     The string
    :returns:       The hex byte.
    */
  class func getHex(byte: String) -> UInt8? {
    switch(countElements(byte)) {
    case 1:
      switch(byte) {
      case "A": return 10
      case "B": return 11
      case "C": return 12
      case "D": return 13
      case "E": return 14
      case "F": return 15
      default:
        if let int = byte.toInt() {
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

    :param: key     A string with the hexadecimal encoding of the encryption
                    key.
    */
  init(key hexKey: String) {
    var keyData = NSMutableData()
    for indexOfByte in (0..<countElements(hexKey)/2) {
      let range = Range(start: advance(hexKey.startIndex, indexOfByte), end: advance(hexKey.startIndex, indexOfByte + 2))
      if var byte = AesEncryptor.getHex(hexKey.substringWithRange(range)) {
        keyData.appendBytes(&byte, length: 1)
      }
    }
    let keyParams = [
      kSecAttrKeyType as NSString: kSecAttrKeyTypeAES as NSString,
      kSecAttrKeySizeInBits as NSString: NSNumber(int: 256)
    ]
    let key = SecKeyCreateFromData(keyParams, keyData, nil)
    encryptor = SecEncryptTransformCreate(key.takeUnretainedValue(), nil)
    decryptor = SecDecryptTransformCreate(key.takeUnretainedValue(), nil)
    key.release()
  }
  
  /**
    This method deinitializes the encryptor.

    This will release our hold on the underlying security transforms.
    */
  deinit {
    encryptor.release()
    decryptor.release()
  }

  /**
    This method encrypts data with our key.

    :param: data      The plaintext.
    :returns:         The encrypted data.
    */
  func encrypt(data: NSData) -> NSData {
    SecTransformSetAttribute(encryptor.takeUnretainedValue(), kSecTransformInputAttributeName, data, nil)
    return SecTransformExecute(encryptor.takeUnretainedValue(), nil) as NSData
  }
  
  /**
    This method ecrypts data with our key.

    :param: data    The encrypted data.
    :returns:       The plaintext.
    */
  func decrypt(data: NSData) -> NSData {
    SecTransformSetAttribute(decryptor.takeUnretainedValue(), kSecTransformInputAttributeName, data, nil)
    return SecTransformExecute(decryptor.takeUnretainedValue(), nil) as NSData
  }
  
  //MARK: - Key Generation
  
  /**
    This method generates an AES key.

    :returns:   The hexadecimal encoding of the key.
    */
  class func generateKey() -> String {
    let keyParams = [
      kSecAttrKeyType as NSString: kSecAttrKeyTypeAES as NSString,
      kSecAttrKeySizeInBits as NSString: NSNumber(int: 256)
    ]
    let key = SecKeyGenerateSymmetric(keyParams, nil)
    var dataContainer: Unmanaged<NSData>? = nil
    SecItemExport(key.takeUnretainedValue(), UInt32(kSecFormatUnknown), 0, nil, &dataContainer)
    
    
    var keyString = ""
    
    if dataContainer != nil {
      let data = dataContainer!.takeUnretainedValue()
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