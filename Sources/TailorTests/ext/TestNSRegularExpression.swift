@testable import Tailor
import TailorTesting
import XCTest
import Foundation

struct TestNSRegularExpression : XCTestCase, TailorTestable {
  var allTests: [(String, () throws -> Void)] { return [
    ("testCanCreateExpressionWithStartAnchor", testCanCreateExpressionWithStartAnchor),
    ("testCanCreateExpressionWithEndAnchor", testCanCreateExpressionWithEndAnchor),
    ("testCanCreateExpressionWithOptionalCharacter", testCanCreateExpressionWithOptionalCharacter),
    ("testCanCreateExpressionWithWildcard", testCanCreateExpressionWithWildcard),
    ("testCanCreateExpressionWithMetaclassWithRange", testCanCreateExpressionWithMetaclassWithRange),
    ("testCanCreateExpressionWithMetaclassWithDashAtEnd", testCanCreateExpressionWithMetaclassWithDashAtEnd),
    ("testCanCaptureSubgroups", testCanCaptureSubgroups),
    ("testCanCaptureNestedSubgroups", testCanCaptureNestedSubgroups),
    ("testCanCaptureSubgroupsWithRepetition", testCanCaptureSubgroupsWithRepetition),
    ("testMatchingHeaderLine", testMatchingHeaderLine),
  ]}

  func setUp() {
    setUpTestCase()
  }
  
  func testCanCreateExpressionWithStartAnchor() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "^bc")
      let result1 = expression.matchesInString("bcd", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 0)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("abc", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
    }
  }
  
  func testCanCreateExpressionWithEndAnchor() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "bc$")
      let result1 = expression.matchesInString("abc", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 1)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("bcd", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
    }
  }
  
  func testCanCreateExpressionWithOptionalCharacter() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "bc?")
      let result1 = expression.matchesInString("abcc", options: [], range: NSMakeRange(0,4))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 1)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("abd", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 1)
      assert(result2.first?.range.location, equals: 1)
      assert(result2.first?.range.length, equals: 1)
      let result3 = expression.matchesInString("ad", options: [], range: NSMakeRange(0,2))
      assert(result3.count, equals: 0)
    }
  }
  
  func testCanCreateExpressionWithWildcard() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a.b")
      let result1 = expression.matchesInString("acb", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 0)
      assert(result1.first?.range.length, equals: 3)
      let result2 = expression.matchesInString("ab", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
    }
  }
  
  func testCanCreateExpressionWithMetaclassWithRange() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a[0-5]")
      let result1 = expression.matchesInString("a2b", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 0)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("a6", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
    }
  }
  
  func testCanCreateExpressionWithMetaclassWithDashAtEnd() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a[0-]")
      let result1 = expression.matchesInString("a-b", options: [], range: NSMakeRange(0,3))
      assert(result1.count, equals: 1)
      assert(result1.first?.range.location, equals: 0)
      assert(result1.first?.range.length, equals: 2)
      let result2 = expression.matchesInString("a6", options: [], range: NSMakeRange(0,2))
      assert(result2.count, equals: 0)
    }
  }
  
  func testCanCaptureSubgroups() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a(bc*)")
      let results = expression.matchesInString("abccd", options: [], range: NSMakeRange(0,5))
      assert(results.count, equals: 1)
      if results.count < 1 { return }
      let result = results[0]
      assert(result.range.location, equals: 0)
      assert(result.range.length, equals: 4)
      assert(result.numberOfRanges, equals: 2)
      if result.numberOfRanges < 2 { return }
      assert(result.rangeAtIndex(0).location, equals: 0)
      assert(result.rangeAtIndex(0).length, equals: 4)
      assert(result.rangeAtIndex(1).location, equals: 1)
      assert(result.rangeAtIndex(1).length, equals: 3)
    }
  }
  
  func testCanCaptureNestedSubgroups() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a(bc(d|e)f)")
      let results = expression.matchesInString("abcdfg", options: [], range: NSMakeRange(0,6))
      assert(results.count, equals: 1)
      if results.count < 1 { return }
      let result = results[0]
      assert(result.range.location, equals: 0)
      assert(result.range.length, equals: 5)
      assert(result.numberOfRanges, equals: 3)
      if result.numberOfRanges < 3 { return }
      assert(result.rangeAtIndex(0).location, equals: 0)
      assert(result.rangeAtIndex(0).length, equals: 5)
      assert(result.rangeAtIndex(1).location, equals: 1)
      assert(result.rangeAtIndex(1).length, equals: 4)
      assert(result.rangeAtIndex(2).location, equals: 3)
      assert(result.rangeAtIndex(2).length, equals: 1)
    }
  }
  
  func testCanCaptureSubgroupsWithRepetition() {
    assertNoExceptions {
      let expression = try NSRegularExpression(pattern: "a(bc)*d")
      let results = expression.matchesInString("abcbcbcdefg", options: [], range: NSMakeRange(0,11))
      assert(results.count, equals: 1)
      if results.count < 1 { return }
      let result = results[0]
      assert(result.range.location, equals: 0)
      assert(result.range.length, equals: 8)
      assert(result.numberOfRanges, equals: 2)
      if result.numberOfRanges < 2 { return }
      assert(result.rangeAtIndex(0).location, equals: 0)
      assert(result.rangeAtIndex(0).length, equals: 8)
      assert(result.rangeAtIndex(1).location, equals: 5)
      assert(result.rangeAtIndex(1).length, equals: 2)
    }
  }
  
  func testMatchingHeaderLine() {
    let expression = try! NSRegularExpression(pattern: "^([\\w-]*):[ \t]*(.*)$")
    let line = "X-Custom-Field: header value"
    let results = expression.matchesInString(line, options: [], range: NSMakeRange(0, line.characters.count))
    assert(!results.isEmpty)
    if results.isEmpty { return }
    let result = results[0]
    assert(result.numberOfRanges, equals: 3)
    if result.numberOfRanges < 3 { return }
    assert(result.rangeAtIndex(0).location, equals: 0)
    assert(result.rangeAtIndex(0).length, equals: 28)
    assert(result.rangeAtIndex(1).location, equals: 0)
    assert(result.rangeAtIndex(1).length, equals: 14)
    assert(result.rangeAtIndex(2).location, equals: 16)
    assert(result.rangeAtIndex(2).length, equals: 12)
  }
}