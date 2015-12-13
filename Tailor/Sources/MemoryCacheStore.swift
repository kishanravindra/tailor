import Foundation

/**
  This class provides an in-memory cache store backed by NSCache.
  */
public final class MemoryCacheStore: CacheImplementation {
  /** The internal storage. */
  let cache = NSCache()
  
  /** The times when we should clear keys from the cache. */
  public var expiryTimes = [String:Timestamp]()

  /**
    This method initializes an empty cache store.
    */
  public init() { }
  
  /**
    This method reads an entry for the cache store.

    - parameter key:    The key for the cache entry.
    - returns:          The fetched value.
    */
  public func read(key: String) -> String? {
    if let time = expiryTimes[key] {
      if time < Timestamp.now() {
        return nil
      }
    }
    return (cache.objectForKey(key.bridge()) as? NSString)?.bridge()
  }
  
  /**
    This method stores a value in the cache.

    - parameter key:           The key for the cache entry.
    - parameter value:         The value to store in the cache.
    - parameter expiryTime:    The time until the cache entry should expire.
    */
  public func write(key: String, value: String, expireIn expiryTime: TimeInterval?=nil) {
    cache.setObject(value.bridge(), forKey: key.bridge())
    if expiryTime != nil {
      expiryTimes[key] = expiryTime?.fromNow
    }
  }
  
  /**
    This method removes an entry from the cache.

    - parameter key:     The key for the entry to remove.
    */
  public func clear(key: String) {
    cache.removeObjectForKey(key.bridge())
  }
  
  /**
    This method removes all the entries from the cache.
    */
  public func clear() {
    cache.removeAllObjects()
  }
}
