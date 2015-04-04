import Foundation

public extension String {
  /** The string with the first character lowercased. */
  public var lowercaseInitial: String {
    get {
      return String(self[self.startIndex]).lowercaseString +
        self.substringFromIndex(advance(self.startIndex, 1))
      
    }
  }
  
  /** The string with the first character capitalized. */
  public var capitalizeInitial: String {
    get {
      return String(self[self.startIndex]).capitalizedString +
        self.substringFromIndex(advance(self.startIndex, 1))
      
    }
  }
  
  /** The string converted into a plural form. */
  public var pluralized : String {
    let replacements = [
      "y": "ies",
      "o": "oes",
      "s": "ses"
    ]
    for (suffix, pluralSuffix) in replacements {
      if self.hasSuffix(suffix) {
        return self.substringToIndex(advance(self.startIndex, count(self) - count(suffix))) + pluralSuffix
      }
    }
    return self + "s"
  }
  
  /** Whether this string contains another one. */
  public func contains(other: String) -> Bool {
    return self.rangeOfString(other) != nil
  }
  
  /**
    Whether this string matches a regular expression.
  
    :param: pattern         The pattern to compare against
    :param: allowPartial    Whether we should allow partial matches. If this is
                            false, the pattern will have to match against the
                            entire string.
    :returns:               Whether this string matches the given pattern.
    */
  public func matches(pattern: String, allowPartial: Bool = false) -> Bool {
    var fullPattern = allowPartial ? pattern : "^\(pattern)$"
    let expression = NSRegularExpression(pattern: fullPattern, options: nil, error: nil)
    if expression == nil {
      return false
    }
    let range = NSRange(location: 0, length: count(self))
    let results = expression!.numberOfMatchesInString(self, options: nil, range: range)
    return results > 0
  }
}