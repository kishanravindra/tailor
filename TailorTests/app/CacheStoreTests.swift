import XCTest
import Tailor
import TailorTesting

class CacheStoreTests: TailorTestCase {
  class TestCacheStore : CacheStore {
    var data = [String:String]()
    var expiries = [String:TimeInterval]()
    
    override func read(key: String)->String? {
      return data[key]
    }
    
    override func write(key: String, value: String, expireIn expiryTime: TimeInterval? = nil) {
      data[key] = value
      if expiryTime != nil {
        expiries[key] = expiryTime!
      }
    }
  }
  
  override func setUp() {
    super.setUp()
    Application.start()
    SHARED_CACHE_STORE = nil
  }
  
  override func tearDown() {
    super.tearDown()
    SHARED_CACHE_STORE = nil
  }
  
  func testFetchWithEmptyCacheReturnsResultFromGenerator() {
    let store = TestCacheStore()
    let result = store.fetch("cache.test") { "a" }
    
    assert(result, equals: "a", message: "gets the result from the generator")
  }
  
  func testFetchOnlyCallsGeneratorOnce() {
    let store = TestCacheStore()
    let result1 = store.fetch("cache.test") { "a" }
    let result2 = store.fetch("cache.test") {
      assert(false, message: "Does not call the second generator")
      return "a"
    }
    
    assert(result1, equals: "a", message: "gets the result from the generator")
    assert(result2, equals: "a", message: "gets the result from the generator")
  }
  
  func testFetchWithCacheHitReturnsCachedValue() {
    let store = TestCacheStore()
    store.write("cache.test", value: "b")
    let result = store.fetch("cache.test") {
      XCTFail("Should not call the generator")
      return "a"
    }
    
    assert(result, equals: "b", message: "uses the cached value instead of the generated one")
  }
  
  func testFetchWithExpiryTimeGivesExpiryTimeToWriteMethod() {
    let store = TestCacheStore()
    store.fetch("cache.test", expireIn: 20.seconds) { "a" }
    
    let expiry = store.expiries["cache.test"]
    assert(expiry, equals: 20.seconds, message: "sets the expiry time from the call to fetch")
  }
  
  func testSharedCacheStoreReturnsWithNoConfigurationSettingReturnsMemoryCacheStore() {
    let store = CacheStore.shared()
    let name = reflect(store).summary
    assert(name, equals: "Tailor.MemoryCacheStore", message: "returns a memory cache store")
  }
  
  func testSharedCacheStoreWithConfigurationSettingReturnsThatType() {
    Application.sharedApplication().configuration["cache.class"] = "Tailor.CacheStore"
    let store = CacheStore.shared()
    let name = reflect(store).summary
    assert(name, equals: "Tailor.CacheStore", message: "returns a cache store with the specified type")
  }
  
  func testSharedCacheStoreOnlyCreatesOneStore() {
    let store1 = CacheStore.shared()
    store1.write("cache.test", value: "test value")
    let store2 = CacheStore.shared()
    let value = store2.read("cache.test")
    assert(value, equals: "test value")
  }
}
