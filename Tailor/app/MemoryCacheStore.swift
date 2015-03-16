import Foundation

/**
  This class provides an in-memory cache store backed by NSCache.
  */
public class MemoryCacheStore: CacheStore {
  /** The internal storage. */
  let cache = NSCache()
  
  /** The times when we should clear keys from the cache. */
  public var expiryTimes = [String:NSDate]()

  public override func read(key: String) -> String? {
    if let time = expiryTimes[key] {
      if time.timeIntervalSinceNow < 0 {
        expiryTimes.removeValueForKey(key)
        cache.removeObjectForKey(key)
      }
    }
    return cache.objectForKey(key) as? String
  }
  
  public override func write(key: String, value: String, expireIn expiryTime: NSTimeInterval?=nil) {
    cache.setObject(value, forKey: key)
    if expiryTime != nil {
      expiryTimes[key] = NSDate(timeIntervalSinceNow: expiryTime!)
    }
  }
  
  public override func clear(key: String) {
    cache.removeObjectForKey(key)
  }
  
  public override func clear() {
    cache.removeAllObjects()
  }
}
