import Foundation
import CoreFoundation

#if os(Linux)
  extension NSBundle {
    //FIXME
    class func allBundles() -> [NSBundle] {
      return []
    }
  }

  //FIXME
  extension NSPropertyListMutabilityOptions {
      public static let Immutable = NSPropertyListMutabilityOptions(rawValue: 0)
      public static let MutableContainers = NSPropertyListMutabilityOptions(rawValue: 1)
      public static let MutableContainersAndLeaves = NSPropertyListMutabilityOptions(rawValue: 2)
  }

  //FIXME
    public func NSLog(format: String) {
      NSLog(format, "")
    }
    public func NSLog(format: String, _ arguments: String...) {
      var result = format.bridge()
      for argument in arguments {
        let range = result.rangeOfString("%@")
        if range.location == NSNotFound { return }
        result = result.stringByReplacingCharactersInRange(range, withString: argument).bridge()
      }
      print(result)
    }
    public func NSLog(format: String, _ arguments: CVarArgType...) {
      print("Getting va list")
        withVaList(arguments) {
          va_list in
          print("Got list")
          let string = NSString(format: format, arguments: va_list)
          print(string)
        }
    }

  public extension NSData {
    //FIXME
    public func rangeOfData(dataToFind: NSData, options mask: NSDataSearchOptions, range searchRange: NSRange) -> NSRange {
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

@noreturn internal func NSUnimplemented(fn: String = __FUNCTION__, file: StaticString = __FILE__, line: UInt = __LINE__) {
  fatalError("\(fn) is not yet implemented", file: file, line: line)
}