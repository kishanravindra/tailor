import Foundation

/**
  This class provides a sanitizer for SQL strings.

  It escapes backslashes, double quotes, and single quotes, by prefixing them
  with a backslash.
  */
public class SqlSanitizer : Sanitizer {
  /** This method creates the sanitizer. */
  public required init() {
    super.init()
  }
  
  /** This method gets the mapping for the sanitizer. */
  public override class func mapping() -> [Character:String] { return [
      "\\": "\\\\",
      "\"": "\\\"",
      "'": "\\'"
    ] }
}