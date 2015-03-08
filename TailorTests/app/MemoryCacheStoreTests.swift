import XCTest

class MemoryCacheStoreTests: XCTestCase {
  let store = MemoryCacheStore()
  
  override func setUp() {
    store.write("key1", value: "value1")
    store.write("key2", value: "value2")
  }
  
  func testMemoryCacheStoreCanStoreValues() {
    let value1 = store.read("key1")
    let value2 = store.read("key2")
    
    XCTAssertNotNil(value1)
    if value1 != nil {
      XCTAssertEqual(value1!, "value1")
    }
    
    XCTAssertNotNil(value2)
    if value2 != nil {
      XCTAssertEqual(value2!, "value2")
    }
  }
  
  func testMemoryCacheCanClearValue() {
    store.clear("key1")
    XCTAssertNil(store.read("key1"), "clears the requested value")
    XCTAssertNotNil(store.read("key2"), "leaves other values intact")
  }
  
  func testMemoryCacheCanClearAllValues() {
    store.clear()
    XCTAssertNil(store.read("key1"), "clears all values")
    XCTAssertNil(store.read("key2"), "clears all values")
  }
}
