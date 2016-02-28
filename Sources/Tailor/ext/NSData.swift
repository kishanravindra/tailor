import Foundation
import COpenSSL
#if os(Linux)
  import Glibc
#endif

public extension NSData {
  /**
    This method initializes an NSData object from a byte array.

    - parameter bytes:   The array of bytes.
    */
  public convenience init<T: CollectionType where T.Generator.Element == UInt8, T.Index.Distance == Int>(bytes: T) {
    let length = bytes.count
    let buffer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>(malloc(length))
    for (index,byte) in bytes.enumerate() {
      buffer[index] = byte
    }
    self.init(bytes: buffer, length: length)
    free(buffer)
  }
  
  /**
    This method searches for a string in this data and uses it to separate out
    subcomponents of the data.

    - parameter separator:    The separator between the components
    - parameter limit:        The maximum number of components to create. Once
                              this is reached, the rest of the data will be kept
                              as one piece.
    - returns:                The subcomponents.
    */
  public func componentsSeparatedByString(separator: String, limit: Int? = nil) -> [NSData] {
    var components = [NSData]()
    let separatorData = NSData(bytes: separator.utf8)
    if self.length == 0 {
      return [self]
    }
    var searchRange = NSRange(location: 0, length: self.length)
    while(true) {
      let matchRange = self.rangeOfData(separatorData, options: [], range: searchRange)
      if matchRange.location == NSNotFound {
        break
      }
      let componentRange = NSRange(location: searchRange.location, length: matchRange.location - searchRange.location)
      components.append(self.subdataWithRange(componentRange))
      searchRange.location += componentRange.length + matchRange.length
      searchRange.length -= componentRange.length + matchRange.length
      
      if let limit = limit {
        if components.count == limit - 1 {
          break
        }
      }
    }
    if searchRange.length > 0 {
      components.append(self.subdataWithRange(searchRange))
    }
    return components
  }
  
  /**
    This method gets an MD5 hash of the data.
   
    FIXME
    */
  public var md5Hash: String {
    let data = ShaPasswordHasher.hashData(self, digest: EVP_md5())
    let buffer = [UInt8](count: data.length, repeatedValue: 0)
    data.getBytes(UnsafeMutablePointer<Void>(buffer), length: buffer.count)
    let output = NSMutableString(capacity: 2 * CC_MD5_DIGEST_LENGTH)
    for byte in buffer {
      output.appendString(AesEncryptor.getHexString(byte))
    }
    return output.bridge()
  }
}

extension NSMutableData {
  /**
    This method adds bytes to an NSData object from a byte array.

    - parameter bytes:   The array of bytes.
    */
  public func appendBytes<T: CollectionType where T.Generator.Element == UInt8, T.Index.Distance == Int>(bytes: T) {
    let length = bytes.count
    let buffer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>(malloc(length))
    for (index,byte) in bytes.enumerate() {
      buffer[index] = byte
    }
    self.appendBytes(buffer, length: length)
    free(buffer)
  }
}

let CC_MD5_DIGEST_LENGTH = 16