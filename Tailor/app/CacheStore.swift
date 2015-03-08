import Foundation

/**
  This class provides a cache store, which is responsible for caching
  information across requests.
  */
public class CacheStore {
  /**
    This method initializes an empty cache store.

    All subclasses must implement this method in order to be dynamically
    initialized as the shared cache store.
    */
  public required init() {
    
  }
  
  //MARK: - Cache Access
  
  /**
    This method reads a value from the cache.

    :param: key   The key for the cache entry.
    :returns:     The value that is stored in the cache.
    */
  public func read(key: String) -> String? {
    return nil
  }
  
  /**
    This method stores a value in the cache.

    :param: key     The identifier for the cache entry.
    :param: value   The value to store.
    */
  public func write(key: String, value: String) {
  }
  
  /**
    This method removes a value from the cache.

    :param: key   The identifier for the cache entry.
    */
  public func clear(key: String) {
    
  }
  
  /**
    This method removes all values form the cache.
    */
  public func clear() {
    
  }
  
  /**
    This method gets a value from the cache.

    If there is no value in the cache, the generator function will be run to
    get it.

    :param: key         The identifier for the cache entry.
    :param: generator   The function to generate a value on a cache miss.
    :returns:           The value provided by the cache or the generator.
    */
  public func fetch(key: String, generator: ()->String) -> String {
    if let result = self.read(key) {
      return result
    }
    else {
      let result = generator()
      self.write(key, value: result)
      return result
    }
  }
  
  /**
    This method gets the shared cache store.

    There will be one shared cache store instance, which will be shared across
    all threads. It will be initialized the first time this method is called.

    The type of the cache store is specified by the cache.class configuration
    setting. If there is no setting for it, it will fall back to using a
    MemoryCacheStore.

    :returns:   The cache store.
    */
  public class func shared() -> CacheStore {
    if SHARED_CACHE_STORE == nil {
      let name = Application.sharedApplication().configuration["cache.class"]
      let type = NSClassFromString(name) as? CacheStore.Type ?? MemoryCacheStore.self
      SHARED_CACHE_STORE = type.init()
    }
    return SHARED_CACHE_STORE
  }
}

internal var SHARED_CACHE_STORE: CacheStore!