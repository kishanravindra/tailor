import XCTest
import Tailor

class ArrayTests: XCTestCase {
  func testRemoveNilsProducesArrayWithoutNils() {
    let input : [String?] = ["a", "b", nil, "c", nil]
    let output = removeNils(input)
    XCTAssertEqual(output, ["a", "b", "c"], "returns the original array with nils removed")
  }
}
