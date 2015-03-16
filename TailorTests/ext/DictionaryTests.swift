import XCTest
import Tailor

class DictionaryTests: XCTestCase {
  func testMergeContainsValues() {
    let d1 = ["a": "27", "b": "15"]
    let d2 = ["b": "19", "c": "28"]
    let result = merge(d1, d2)
    let keys = sorted(result.keys.array)
    XCTAssertEqual(keys, ["a", "b", "c"], "has all keys from the two inputs")
    if keys == ["a", "b", "c"] {
      XCTAssertEqual(result["a"]!, "27", "gets a value from the first dictionary")
      XCTAssertEqual(result["c"]!, "28", "gets a value from the second dictionary")
      XCTAssertEqual(result["b"]!, "19", "overrides values from first dictionary with second dictionary")
    }
  }
}
