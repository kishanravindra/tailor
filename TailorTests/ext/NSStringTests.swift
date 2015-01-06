import XCTest

class NSStringTests: XCTestCase {
  func testCamelCaseCanConvertString() {
    let result = "test_string".camelCase()
    XCTAssertEqual(result, "testString", "converts to camel case")
  }
  
  func testCamelCaseCanCapitalizeString() {
    let result = "test_string".camelCase(capitalize: true)
    XCTAssertEqual(result, "TestString", "converts to capitalized camel case")
  }
  
  func testUnderscoredConvertsToSnakeCase() {
    let result = "TestString".underscored()
    XCTAssertEqual(result, "test_string", "converts to snake case")
  }
}
