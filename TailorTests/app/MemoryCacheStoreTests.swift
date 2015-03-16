import XCTest
import Tailor

class MemoryCacheStoreTests: XCTestCase {
  let store = MemoryCacheStore()
  
  override func setUp() {
    store.write("key1", value: "value1")
    store.write("key2", value: "value2")
  }
  
  func testCanWriteAndReadValues() {
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
  
  func testReadWithFutureExpiryTimeReadsValue() {
    store.expiryTimes["key1"] = NSDate(timeIntervalSinceNow: 60)
    XCTAssertNotNil(store.read("key1"), "returns a value")
  }
  
  func testReadWithPastExpiryTimeClearsValue() {
    store.expiryTimes["key1"] = NSDate(timeIntervalSinceNow: -60)
    let result = store.read("key1")
    XCTAssertNil(result, "returns a nil value")
    XCTAssertNil(store.expiryTimes["key1"], "removes the expiry time")
  }

  func testWriteSetsExpiryTime() {
    store.write("key3", value: "value3", expireIn: 3600)
    let time = store.expiryTimes["key3"]
    XCTAssertNotNil(time, "sets the expiry time")
    if time != nil {
      XCTAssertEqualWithAccuracy(time!.timeIntervalSinceNow, 3600, 5, "sets the expiry time to the specified interval in the future")
    }
  }
  
  func testCanClearValue() {
    store.clear("key1")
    XCTAssertNil(store.read("key1"), "clears the requested value")
    XCTAssertNotNil(store.read("key2"), "leaves other values intact")
  }
  
  func testCanClearAllValues() {
    store.clear()
    XCTAssertNil(store.read("key1"), "clears all values")
    XCTAssertNil(store.read("key2"), "clears all values")
  }
}
