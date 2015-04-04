import XCTest
import Tailor
import TailorTesting

class SqlSanitizerTests: TailorTestCase {
  func testSqlSanitizerReplacesSqlEscapeCharacters() {
    let result = SqlSanitizer().sanitizeString("BOBBY '; DROP TABLE \\ students\"")
    assert(result, equals: "BOBBY \\'; DROP TABLE \\\\ students\\\"", message: "sanitizes all escape characters")
  }
}
