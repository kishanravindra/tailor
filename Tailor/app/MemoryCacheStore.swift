import Foundation

/**
  This class provides an in-memory cache store backed by NSCache.
  */
public class MemoryCacheStore: CacheStore {
  /** The internal storage. */
  let cache = NSCache()
  
  /** The times when we should clear keys from the cache. */
  public var expiryTimes = [String:Timestamp]()

  /**
    This method reads an entry for the cache store.

    - parameter key:    The key for the cache entry.
    - returns:          The fetched value.
    */
  public override func read(key: String) -> String? {
    if let time = expiryTimes[key] {
      if time < Timestamp.now() {
        expiryTimes.removeValueForKey(key)
        cache.removeObjectForKey(key)
      }
    }
    return cache.objectForKey(key) as? String
  }
  
  /**
    This method stores a value in the cache.

    - parameter key:           The key for the cache entry.
    - parameter value:         The value to store in the cache.
    - parameter expiryTime:    The time until the cache entry should expire.
    */
  public override func write(key: String, value: String, expireIn expiryTime: TimeInterval?=nil) {
    cache.setObject(value, forKey: key)
    if expiryTime != nil {
      expiryTimes[key] = expiryTime!.fromNow
    }
  }
  
  /**
    This method removes an entry from the cache.

    - parameter key:     The key for the entry to remove.
    */
  public override func clear(key: String) {
    cache.removeObjectForKey(key)
  }
  
  /**
    This method removes all the entries from the cache.
    */
  public override func clear() {
    cache.removeAllObjects()
  }
}
