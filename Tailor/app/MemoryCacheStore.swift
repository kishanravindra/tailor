import Cocoa

/**
  This class provides an in-memory cache store backed by NSCache.
  */
class MemoryCacheStore: CacheStore {
  /** The internal storage. */
  let cache = NSCache()

  override func read(key: String) -> String? {
    return cache.objectForKey(key) as? String
  }
  
  override func write(key: String, value: String) {
    cache.setObject(value, forKey: key)
  }
  
  override func clear(key: String) {
    cache.removeObjectForKey(key)
  }
  
  override func clear() {
    cache.removeAllObjects()
  }
}
