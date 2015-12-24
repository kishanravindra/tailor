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

  extension String: CVarArgType {
    public var _cVarArgEncoding: [Int] {
        return self.bridge()._cVarArgEncoding
    }
  }

  extension NSObject : CVarArgType {
      /// Transform `self` into a series of machine words that can be
      /// appropriately interpreted by C varargs
      public var _cVarArgEncoding: [Int] {
        return _encodeBitsAsWords(self)
      }
    }

  //FIXME
    public func NSLog(format: String, _ arguments: CVarArgType...) {
        print(format)
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
        
        if let _valueObject = key as? AnyObject {
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