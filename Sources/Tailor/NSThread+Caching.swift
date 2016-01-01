import Foundation

extension NSThread {
  /**
    This method caches a value in the thread dictionary.
 
    - parameter key:    The key that the value will be stored in in the thread
                        dictionary.
    - parameter valueGenerator:   A block for generating the value.
    - returns:          The cached or generated value.
    */
  public static func cacheInDictionary<T: AnyObject>(key: String, valueGenerator: Void->T) -> T {
    #if os(Linux)
      var dictionary = NSThread.currentThread().threadDictionary
    #else
      let dictionary = NSThread.currentThread().threadDictionary
    #endif
    if let value = dictionary[key] as? T {
      return value
    }
    let value = valueGenerator()
    dictionary[key] = value
    #if os(Linux)
      NSThread.currentThread().threadDictionary = dictionary
    #endif
    return value
  }
}