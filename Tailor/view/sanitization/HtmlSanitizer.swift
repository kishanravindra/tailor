import Foundation

/**
  This class provides a sanitizer for making text HTML-safe.

  It will escape left brackets, right brackets, ampersands, double quotes, and
  single quotes.
  */
public class HtmlSanitizer : Sanitizer {
  /** This method creates a sanitizer. */
  public required init() {
    super.init()
  }
  
  /** This method gets the mapping for the sanitizer. */
  public override class func mapping() -> [Character:String] { return [
      "<": "&lt;",
      ">": "&gt;",
      "&": "&amp;",
      "\"": "&quot;",
      "'": "&#39;"
    ]  }
}