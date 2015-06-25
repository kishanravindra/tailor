/**
  This class provides a cache store, which is responsible for caching
  information across requests.

  This class has been deprecated in favor of the CacheImplementation protocol.
  */
@available(*, deprecated, message="Use the CacheImplementation protocol instead") public class CacheStore: CacheImplementation {
  /**
    This method initializes an empty cache store.

    All subclasses must implement this method in order to be dynamically
    initialized as the shared cache store.
    */
  public required init() {
    
  }
  
  //MARK: - Raw Cache Access
  
  /**
    This method reads a value from the cache.

    - parameter key:    The key for the cache entry.
    - returns:          The value that is stored in the cache.
    */
  public func read(key: String) -> String? {
    return nil
  }
  
  /**
    This method stores a value in the cache.

    - parameter key:          The identifier for the cache entry.
    - parameter value:        The value to store.
    - parameter expiryTime:   The time until the cache entry should expire. If
                              this is nil, the entry will remain for as long as
                              the specific cache store can keep it.
    */
  public func write(key: String, value: String, expireIn expiryTime: TimeInterval? = nil) {
  }
  
  /**
    This method removes a value from the cache.

    - parameter key:   The identifier for the cache entry.
    */
  public func clear(key: String) {
    
  }
  
  /**
    This method removes all values from the cache.
    */
  public func clear() {
    
  }
  
  //MARK: - Initialization
  
  /**
    This method gets the shared cache store.
    
    There will be one shared cache store instance, which will be shared across
    all threads. It will be initialized the first time this method is called.
    
    The type of the cache store is specified by the cache.class configuration
    setting. If there is no setting for it, it will fall back to using a
    MemoryCacheStore.
    
    - returns:   The cache store.
    */
  public class func shared() -> CacheStore {
    return Application.cache as! CacheStore
  }
}