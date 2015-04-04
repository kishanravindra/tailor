import XCTest
import TailorTesting

class NSStringTests: TailorTestCase {
  func testCamelCaseCanConvertString() {
    let result = "test_string".camelCase()
    assert(result, equals: "testString", message: "converts to camel case")
  }
  
  func testCamelCaseCanCapitalizeString() {
    let result = "test_string".camelCase(capitalize: true)
    assert(result, equals: "TestString", message: "converts to capitalized camel case")
  }
  
  func testUnderscoredConvertsToSnakeCase() {
    let result = "TestString".underscored()
    assert(result, equals: "test_string", message: "converts to snake case")
  }
}
