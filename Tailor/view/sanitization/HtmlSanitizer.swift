import Foundation

/**
  This class provides a sanitizer for making text HTML-safe.

  It will escape left brackets, right brackets, ampersands, double quotes, and
  single quotes.
  */
public class HtmlSanitizer : Sanitizer {
  public required init() {
    super.init()
    self.mapping = [
      "<": "&lt;",
      ">": "&gt;",
      "&": "&amp;",
      "\"": "&quot;",
      "'": "&#39;"
    ]
  }
}