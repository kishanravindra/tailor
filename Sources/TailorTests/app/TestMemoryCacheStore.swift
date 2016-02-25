import Tailor
import TailorTesting
import XCTest

struct TestMemoryCacheStore: TailorTestable {
  var store = MemoryCacheStore()
  
  func setUp() {
    setUpTestCase()
    store.clear()
    store.write("key1", value: "value1")
    store.write("key2", value: "value2")
  }

  var allTests: [(String, () throws -> Void)] { return [
    ("testCanWriteAndReadValues", testCanWriteAndReadValues),
    ("testReadWithFutureExpiryTimeReadsValue", testReadWithFutureExpiryTimeReadsValue),
    ("testReadWithPastExpiryTimeGetsNil", testReadWithPastExpiryTimeGetsNil),
    ("testWriteSetsExpiryTime", testWriteSetsExpiryTime),
    ("testCanClearValue", testCanClearValue),
    ("testCanClearAllValues", testCanClearAllValues),
  ]}
  
  func testCanWriteAndReadValues() {
    store.write("key1", value: "value1")
    store.write("key2", value: "value2")
    let value1 = store.read("key1")
    let value2 = store.read("key2")
    assert(value1, equals: "value1")
    assert(value2, equals: "value2")
  }
  
  func testReadWithFutureExpiryTimeReadsValue() {
    store.expiryTimes["key1"] = 60.seconds.fromNow
    assert(isNotNil: store.read("key1"))
  }
  
  func testReadWithPastExpiryTimeGetsNil() {
    store.expiryTimes["key1"] = 60.seconds.ago
    let result = store.read("key1")
    assert(isNil: result, message: "returns a nil value")
  }

  func testWriteSetsExpiryTime() {
    store.write("key3", value: "value3", expireIn: 1.hour)
    let time = store.expiryTimes["key3"]
    assert(isNotNil: time)
    if time != nil {
      let interval = time!.epochSeconds - Timestamp.now().epochSeconds
      assert(interval, within: 5, of: 3600, message: "sets the expiry time to the specified interval in the future")
    }
  }
  
  func testCanClearValue() {
    store.clear("key1")
    assert(isNil: store.read("key1"), message: "clears the requested value")
    assert(isNotNil: store.read("key2"), message: "leaves other values intact")
  }
  
  func testCanClearAllValues() {
    store.clear()
    assert(isNil: store.read("key1"), message: "clears all values")
    assert(isNil: store.read("key2"), message: "clears all values")
  }
}
