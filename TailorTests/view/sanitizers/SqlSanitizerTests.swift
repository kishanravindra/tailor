import XCTest
import Tailor

class SqlSanitizerTests: XCTestCase {
  func testSqlSanitizerReplacesSqlEscapeCharacters() {
    let result = SqlSanitizer().sanitizeString("BOBBY '; DROP TABLE \\ students\"")
    XCTAssertEqual(result, "BOBBY \\'; DROP TABLE \\\\ students\\\"", "sanitizes all escape characters")
  }
}
