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
}
