import Foundation

/**
  This class provides an in-memory cache store backed by NSCache.
  */
public class MemoryCacheStore: CacheStore {
  /** The internal storage. */
  let cache = NSCache()
  
  /** The times when we should clear keys from the cache. */
  public var expiryTimes = [String:NSDate]()

  /**
    This method reads an entry for the cache store.

    :param: key   The key for the cache entry.
    :returns:     The fetched value.
    */
  public override func read(key: String) -> String? {
    if let time = expiryTimes[key] {
      if time.timeIntervalSinceNow < 0 {
        expiryTimes.removeValueForKey(key)
        cache.removeObjectForKey(key)
      }
    }
    return cache.objectForKey(key) as? String
  }
  
  /**
    This method stores a value in the cache.

    :param: key           The key for the cache entry.
    :param: value         The value to store in the cache.
    :param: expiryTime    The time when the cache entry should expire.
    */
  public override func write(key: String, value: String, expireIn expiryTime: NSTimeInterval?=nil) {
    cache.setObject(value, forKey: key)
    if expiryTime != nil {
      expiryTimes[key] = NSDate(timeIntervalSinceNow: expiryTime!)
    }
  }
  
  /**
    This method removes an entry from the cache.

    :param: key     The key for the entry to remove.
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
