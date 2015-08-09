import XCTest
import Tailor
import TailorTesting

class ArrayTests: TailorTestCase {
  @available(*, deprecated) func testRemoveNilsProducesArrayWithoutNils() {
    let input : [String?] = ["a", "b", nil, "c", nil]
    let output = removeNils(input)
    assert(output, equals: ["a", "b", "c"], message: "returns the original array with nils removed")
  }
}
