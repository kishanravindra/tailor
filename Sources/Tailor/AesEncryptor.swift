import Foundation
#if os(Linux)
import COpenSSL
import Glibc
#endif

/**
  This class provides a high-level interface for doing AES encryption.
  FIXME: Audit this more thoroughly.
  TODO: Look into switching to LibreSSL.
  */
public final class AesEncryptor {
  /** The low-level key for the encryption. */
  #if os(Linux)
  private let key: String?
  #else
  private let key: SecKey?
  #endif
  
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
  
    If it's a two character string, it will interpret it as a single byte, and
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
        let bottom = self.getHex(String(byte[byte.startIndex.advancedBy(1)]))
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
      let range = NSRange(location: indexOfByte, length: 2)
      if let byte = AesEncryptor.getHex(hexKey.bridge().substringWithRange(range)) {
        var byte = byte
        keyData.appendBytes(&byte, length: 1)
      }
    }
    
    #if os(Linux)
      self.key = hexKey
    #else 
    let keyParams = [
      kSecAttrKeyType as NSString: kSecAttrKeyTypeAES as NSString,
      kSecAttrKeySizeInBits as NSString: NSNumber(int: 256)
    ]
    
    self.key = SecKeyCreateFromData(keyParams, keyData, nil)
    #endif
  }
  
  //MARK: - Encryption

  #if os(Linux)

  /**
    This method runs an EVP transformation on some data.

    - parameter data:     The data to encrypt or decrypt.
    - parameter encrypt:  Whether to encrypt or decrypt the data.
    - returns:            The transformed data.
    */
  private func transform(data: NSData, encrypt: Bool) -> NSData {
    guard let keyString = self.key?.bridge() else { return NSData() }
    
    let context = EVP_CIPHER_CTX_new()
    let cipher = EVP_aes_256_cbc()
    
    let ivLength = Int(cipher.memory.iv_len)
    
    let initVectorBytes = Array<UInt8>(count: ivLength, repeatedValue: 0)
    var initVectorData = NSData()

    var targetData = data

    if encrypt {
      RAND_bytes(UnsafeMutablePointer<UInt8>(initVectorBytes), Int32(initVectorBytes.count))
      initVectorData = NSData(bytes: initVectorBytes)
    }
    else {
      initVectorData = data.subdataWithRange(NSRange(location: 0, length: ivLength))
      targetData = data.subdataWithRange(NSRange(location: ivLength, length: data.length - ivLength))
      initVectorData.getBytes(UnsafeMutablePointer<Void>(initVectorBytes), length: ivLength)
    }
    let initVector = initVectorBytes.map { AesEncryptor.getHexString($0) }.joinWithSeparator("")

    EVP_CipherInit_ex(context, cipher, nil, UnsafePointer<UInt8>(keyString.cStringUsingEncoding(NSASCIIStringEncoding)), UnsafePointer<UInt8>(initVector.bridge().cStringUsingEncoding(NSASCIIStringEncoding)), encrypt ? 1 : 0)

    let bufferLength = targetData.length
    let buffer = calloc(bufferLength, 1)
    targetData.getBytes(buffer, length: bufferLength)

    let maxBlockSize = Int(cipher.memory.block_size) + bufferLength

    var currentBlockSize: Int32 = 0
    let block = calloc(maxBlockSize, 1)

    let output = NSMutableData()
    if encrypt {
      output.appendData(initVectorData)
    }

    EVP_CipherUpdate(context, UnsafeMutablePointer<UInt8>(block), &currentBlockSize, UnsafeMutablePointer<UInt8>(buffer), Int32(bufferLength))
    output.appendBytes(buffer, length: Int(currentBlockSize))

    EVP_CipherFinal_ex(context, UnsafeMutablePointer<UInt8>(block), &currentBlockSize)
    output.appendBytes(block, length: Int(currentBlockSize))
    
    free(buffer)
    free(block)
    EVP_CIPHER_CTX_free(context)

    return output
  }
  #endif

  /**
    This method encrypts data with our key.

    - parameter data:     The plaintext.
    - returns:            The encrypted data.
    */
  public func encrypt(data: NSData) -> NSData {
    #if os(Linux)
      return transform(data, encrypt: true)
    #else
    guard let key = self.key else { return NSData() }
    let encryptor = SecEncryptTransformCreate(key, nil)
    SecTransformSetAttribute(encryptor, kSecTransformInputAttributeName, data, nil)
    return (SecTransformExecute(encryptor, nil) as? NSData) ?? NSData()
    #endif
  }
  
  /**
    This method decrypts data with our key.

    - parameter data:   The encrypted data.
    - returns:          The plaintext.
    */
  public func decrypt(data: NSData) -> NSData {
    #if os(Linux)
      return self.transform(data, encrypt: false)
    #else
    guard let key = self.key else { return NSData() }
    let decryptor = SecDecryptTransformCreate(key, nil)
    SecTransformSetAttribute(decryptor, kSecTransformInputAttributeName, data, nil)
    return (SecTransformExecute(decryptor, nil) as? NSData) ?? NSData()
    #endif
  }
  
  //MARK: - Key Generation
  
  /**
    This method generates an AES key.

    - returns:   The hexadecimal encoding of the key.
    */
  public class func generateKey() -> String {
    #if os(Linux)
      let bytes = RandomNumber.generateBytes(32)
      let key = bytes.map { getHexString($0) }.joinWithSeparator("")
      return key
    #else
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
    #endif
  }
}

private var AES_RANDOM_SEEDED = false