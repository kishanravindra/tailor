import Foundation
import CoreFoundation

public extension NSJSONSerialization {
  public class func dataWithJSONObjectForTailor(obj: Any, options: NSJSONWritingOptions) throws -> NSData {
    let jsonData = NSMutableData()
    switch(obj) {
    case let dictionary as [String:Any]:
      jsonData.appendBytes("{".utf8)
      for (key,value) in dictionary {
        if jsonData.length > 1 {
          jsonData.appendBytes(",".utf8)
        }
        jsonData.appendData(try self.dataWithJSONObjectForTailor(key, options: options))
        jsonData.appendBytes(":".utf8)
        jsonData.appendData(try self.dataWithJSONObjectForTailor(value, options: options))
      }
      jsonData.appendBytes("}".utf8)
    case let string as String:
      let escapedString = "\"" + Sanitizer.sqlSanitizer.sanitizeString(string) + "\""
      jsonData.appendBytes(escapedString.utf8)
    case let array as [Any]:
      jsonData.appendBytes("[".utf8)
      for value in array {
        if jsonData.length > 1 {
          jsonData.appendBytes(",".utf8)
        }
        jsonData.appendData(try self.dataWithJSONObjectForTailor(value, options: options))
      }
      jsonData.appendBytes("]".utf8)
    case is NSNull:
      jsonData.appendBytes("null".utf8)
    case let number as NSNumber:
      jsonData.appendBytes(number.description.utf8)
    default:
      throw SerializationConversionError.NotValidJsonObject
    }
    return jsonData
  }
}

#if os(Linux)
  extension NSBundle {
    class func allBundles() -> [NSBundle] {
      return []
    }
  }

  extension NSPropertyListMutabilityOptions {
      public static let Immutable = NSPropertyListMutabilityOptions(rawValue: 0)
      public static let MutableContainers = NSPropertyListMutabilityOptions(rawValue: 1)
      public static let MutableContainersAndLeaves = NSPropertyListMutabilityOptions(rawValue: 2)
  }

    public func NSLog(format: String) {
      NSLog(format, "")
    }
    public func NSLog(format: String, _ arguments: String...) {
      var result = format.bridge()
      for argument in arguments {
        let range = result.rangeOfString("%@")
        if range.location == NSNotFound { continue }
        result = result.stringByReplacingCharactersInRange(range, withString: argument).bridge()
      }
      let timestamp = Timestamp.now().format(TimeFormat.Database)
      print(timestamp + ": " + result.bridge())
    }
    public func NSLog(format: String, _ arguments: CVarArgType...) {
        withVaList(arguments) {
          va_list in
          let string = NSString(format: format, arguments: va_list)
          print(string)
        }
    }


  public extension NSData {
    public func rangeOfData(dataToFind: NSData, options mask: NSDataSearchOptions, range searchRange: NSRange) -> NSRange {
      if searchRange.length < dataToFind.length { return NSRange(location: NSNotFound, length: NSNotFound) }

      let bytes = [UInt8](count: searchRange.length, repeatedValue: 0)
      getBytes(UnsafeMutablePointer<Void>(bytes), range: searchRange)
      let searchBytes = [UInt8](count: dataToFind.length, repeatedValue: 0)
      dataToFind.getBytes(UnsafeMutablePointer<Void>(searchBytes), range: NSMakeRange(0, dataToFind.length))
      for startIndex in 0 ..< searchRange.length - dataToFind.length {
        var match = true
        for indexOfByte in 0..<searchBytes.count {
          if bytes[startIndex + indexOfByte] != searchBytes[indexOfByte] {
            match = false
            break
          }
        }
        if match {
          return NSRange(location: searchRange.location + startIndex, length: searchBytes.count)
        }
      }
      return NSRange(location: NSNotFound, length: NSNotFound)
    }
  }

#else
  public extension NSString {
    public func bridge() -> String {
      return self as String
    }
  }
  public extension String {
    public func bridge() -> NSString {
      return self as NSString
    }
  }
  public extension Array where Element: AnyObject {
    public func bridge() -> NSArray {
      return self as NSArray
    }
  }
  public extension Dictionary {
    public func bridge() -> NSDictionary {
      let result = NSMutableDictionary()
      for (key,value) in self {
        let keyObject: NSCopying
        let valueObject: AnyObject
        
        if let _keyObject = key as? NSCopying {
          keyObject = _keyObject
        }
        else if let _keyString = key as? NSString {
          keyObject = _keyString
        }
        else {
          continue
        }
        
        if let _valueObject = value as? AnyObject {
          valueObject = _valueObject
        }
        else if let _valueString = value as? NSString {
          valueObject = _valueString
        }
        else {
          continue
        }
        
        result.setObject(valueObject, forKey: keyObject)
      }
      return result
    }
  }
#endif

@noreturn internal func NSUnimplemented(fn: String = #function, file: StaticString = #file, line: UInt = #line) {
  fatalError("\(fn) is not yet implemented", file: file, line: line)
}