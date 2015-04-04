import Foundation

/**
  This class provides a sanitizer for making text HTML-safe.

  It will escape left brackets, right brackets, ampersands, double quotes, and
  single quotes.
  */
public class HtmlSanitizer : Sanitizer {
  public required init() {
    super.init()
  }
  
  public override class func mapping() -> [Character:String] { return [
      "<": "&lt;",
      ">": "&gt;",
      "&": "&amp;",
      "\"": "&quot;",
      "'": "&#39;"
    ]  }
}