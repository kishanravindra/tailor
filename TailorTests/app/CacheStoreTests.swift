import XCTest

class CacheStoreTests: XCTestCase {
  class TestCacheStore : CacheStore {
    var data = [String:String]()
    override func read(key: String)->String? {
      return data[key]
    }
    
    override func write(key: String, value: String) {
      data[key] = value
    }
  }
  
  override func setUp() {
    super.setUp()
    TestApplication.start()
    SHARED_CACHE_STORE = nil
  }
  
  func testFetchWithEmptyCacheReturnsResultFromGenerator() {
    var store = TestCacheStore()
    let result = store.fetch("cache.test") { "a" }
    
    XCTAssertEqual(result, "a", "gets the result from the generator")
  }
  
  func testFetchOnlyCallsGeneratorOnce() {
    var store = TestCacheStore()
    let result1 = store.fetch("cache.test") { "a" }
    let result2 = store.fetch("cache.test") {
      XCTFail("Does not call the second generator")
      return "a"
    }
    
    XCTAssertEqual(result1, "a", "gets the result from the generator")
    XCTAssertEqual(result2, "a", "gets the result from the generator")
  }
  
  func testFetchWithCacheHitReturnsCachedValue() {
    var store = TestCacheStore()
    store.write("cache.test", value: "b")
    let result = store.fetch("cache.test") {
      XCTFail("Should not call the generator")
      return "a"
    }
    
    XCTAssertEqual(result, "b", "uses the cached value instead of the generated one")
  }
  
  func testSharedCacheStoreReturnsWithNoConfigurationSettingReturnsMemoryCacheStore() {
    let store = CacheStore.shared()
    let name = reflect(store).summary
    XCTAssertEqual(name, "TailorTests.MemoryCacheStore", "returns a memory cache store")
  }
  
  func testSharedCacheStoreWithConfigurationSettingReturnsThatType() {
    Application.sharedApplication().configuration["cache.class"] = "TailorTests.CacheStore"
    let store = CacheStore.shared()
    let name = reflect(store).summary
    XCTAssertEqual(name, "TailorTests.CacheStore", "returns a cache store with the specified type")
  }
  
  func testSharedCacheStoreOnlyCreatesOneStore() {
    let store1 = CacheStore.shared()
    store1.write("cache.test", value: "test value")
    let store2 = CacheStore.shared()
    let value = store2.read("cache.test")
    XCTAssertNotNil(value)
    if value != nil {
      XCTAssertEqual(value!, "test value")
    }
  }
}
