import Foundation

/**
  This class provides a sanitizer for SQL strings.

  It escapes backslashes, double quotes, and single quotes, by prefixing them
  with a backslash.
  */
public class SqlSanitizer : Sanitizer {
  public required init() {
    super.init()
    self.mapping = [
      "\\": "\\\\",
      "\"": "\\\"",
      "'": "\\'"
    ]
  }
}