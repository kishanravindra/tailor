import Foundation

/**
  This protocol describes a cache store, which is responsible for caching
  information across requests.
  */
public protocol CacheImplementation {
  /**
    This method initializes an empty cache store.
  
    This has been deprecated. Cache implementations are no longer required to
    provide any specific initializer, since they will be initialized with the
    specific type and initializer in the configuration settings.
    */
  @available(*, deprecated) init()
  
  
  /**
    This method reads a value from the cache.
    
    - parameter key:    The key for the cache entry.
    - returns:          The value that is stored in the cache.
    */
  func read(key: String) -> String?
  
  
  /**
    This method stores a value in the cache.
    
    - parameter key:          The identifier for the cache entry.
    - parameter value:        The value to store.
    - parameter expiryTime:   The time until the cache entry should expire. If
                              this is nil, the entry will remain for as long as
                              the specific cache store can keep it.
    */
  func write(key: String, value: String, expireIn: TimeInterval?)
  
  
  /**
    This method removes a value from the cache.
    
    - parameter key:   The identifier for the cache entry.
    */
  func clear(key: String)
  
  /**
    This method removes all values from the cache.
    */
  func clear()
}

public extension CacheImplementation {
  
  //MARK: - Fetching
  
  /**
    This method gets a value from the cache.
    
    If there is no value in the cache, the generator function will be run to
    get it.
    
    - parameter key:          The identifier for the cache entry.
    - parameter generator:    The function to generate a value on a cache miss.
    - returns:                The value provided by the cache or the generator.
    */
  public func fetch(key: String, @noescape generator: ()->String)->String {
    return self.fetch(key, expireIn: nil, generator: generator)
  }
  
  /**
    This method gets a value from the cache.
    
    If there is no value in the cache, the generator function will be run to
    get it.
    
    - parameter key:          The identifier for the cache entry.
    - parameter expiryTime:   The time interval until the cache entry should
                              expire.
    - parameter generator:    The function to generate a value on a cache miss.
    - returns:                The value provided by the cache or the generator.
    */
  public func fetch(key: String, expireIn expiryTime: TimeInterval?, @noescape generator: ()->String) -> String {
    if let result = self.read(key) {
      return result
    }
    else {
      let result = generator()
      self.write(key, value: result, expireIn: expiryTime)
      return result
    }
  }
  
  /**
    This method stores a value in the cache with no expiry time.
  
    This is just a wrapper around the other `write` method, passing nil as
    the expiry time.
  
    - parameter key:          The identifier for the cache entry.
    - parameter value:        The value to store.
    */
  func write(key: String, value: String) {
    self.write(key, value: value, expireIn: nil)
  }
}

extension Application {
  /**
    This method gets the shared cache store.

    There will be one shared cache store instance, which will be shared across
    all threads. It will be initialized the first time this method is called.

    The type of the cache store is specified by the cache.class configuration
    setting. If there is no setting for it, it will fall back to using a
    MemoryCacheStore.

    - returns:   The cache store.
    */
  public static var cache: CacheImplementation {
    guard let store = SHARED_CACHE_STORE else {
      let store = Application.configuration.cacheStore()
      SHARED_CACHE_STORE = store
      return store
    }
    return store
  }
}

/** The global cache store. */
public var SHARED_CACHE_STORE: CacheImplementation?