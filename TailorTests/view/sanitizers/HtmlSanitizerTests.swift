import XCTest
import Tailor
import TailorTesting

class HtmlSanitizerTests: TailorTestCase {
  func testHtmlSanitizerHasMappingForEscapeCharacters() {
    let string = HtmlSanitizer().sanitizeString("a < 5 & b > 7 & \"name\"=\"O'Brien\"")
    assert(string, equals: "a &lt; 5 &amp; b &gt; 7 &amp; &quot;name&quot;=&quot;O&#39;Brien&quot;", message: "escapes all special characters")
  }
}
