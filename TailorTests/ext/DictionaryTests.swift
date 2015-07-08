import XCTest
import Tailor
import TailorTesting

class DictionaryTests: TailorTestCase {
  func testMergeContainsValues() {
    let d1 = ["a": "27", "b": "15"]
    let d2 = ["b": "19", "c": "28"]
    let result = merge(d1, d2)
    let keys = result.keys.array.sort()
    assert(keys, equals: ["a", "b", "c"], message: "has all keys from the two inputs")
    if keys == ["a", "b", "c"] {
      assert(result["a"]!, equals: "27", message: "gets a value from the first dictionary")
      assert(result["c"]!,equals: "28", message:  "gets a value from the second dictionary")
      assert(result["b"]!, equals: "19", message: "overrides values from first dictionary with second dictionary")
    }
  }
  
  func testMapCreatesDictionaryWithKeysMappedToNewValues() {
    let dictionary = ["a": 12, "b": 17]
    let mapped = dictionary.map { $0 * 2 }
    assert(mapped, equals: ["a": 24, "b": 34])
  }
  
  func testMapWithThrowableWithNoExceptionCreatesDictionary() {
    let dictionary = ["a": 12, "b": 17]
    do {
      let mapped = try dictionary.map {
        (value: Int) throws -> Int in
        if value == 0 {
          throw NSError(domain: "my domain", code: 27, userInfo: [:])
        }
        return value + 1
      }
      assert(mapped, equals: ["a": 13, "b": 18])
    }
    catch {
      assert(false, message: "should not throw exception")
    }
  }
  
  func testMapWithThrowableWithExceptionRethrowsException() {
    let dictionary = ["a": 0, "b": 17]
    do {
      _ = try dictionary.map {
        (value: Int) throws -> Int in
        if value == 0 {
          throw NSError(domain: "my domain", code: 27, userInfo: [:])
        }
        return value + 1
      }
      assert(false, message: "should throw exception")
    }
    catch {
      assert(true, message: "should throw exception")
    }
  }
}
