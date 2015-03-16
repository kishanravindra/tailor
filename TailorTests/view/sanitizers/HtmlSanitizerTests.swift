import XCTest
import Tailor

class HtmlSanitizerTests: XCTestCase {
  func testHtmlSanitizerHasMappingForEscapeCharacters() {
    let string = HtmlSanitizer().sanitizeString("a < 5 & b > 7 & \"name\"=\"O'Brien\"")
    XCTAssertEqual(string, "a &lt; 5 &amp; b &gt; 7 &amp; &quot;name&quot;=&quot;O&#39;Brien&quot;", "escapes all special characters")
  }
}
