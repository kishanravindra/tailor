import XCTest
import Tailor
import TailorTesting
import Foundation

struct TestRandomNumber: XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testGenerateNumberGeneratesNumberInRange", testGenerateNumberGeneratesNumberInRange),
    ("testGenerateBytesGeneratesBufferOfLength", testGenerateBytesGeneratesBufferOfLength),
  ]}

  func setUp() {
    setUpTestCase()
  }

  func testGenerateNumberGeneratesNumberInRange() {
    let number = RandomNumber.generateNumber(UInt16(500))
    assert(number < 500)
  }

  func testGenerateNumberGeneratesDifferentNumbers() {
    let number1 = RandomNumber.generateNumber(Int.max)
    let number2 = RandomNumber.generateNumber(Int.max)
    assert(number1, doesNotEqual: number2)
  }

  func testGenerateBytesGeneratesBufferOfLength() {
    let bytes = RandomNumber.generateBytes(10)
    assert(bytes.count, equals: 10)
  }
}