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
        return self.substringToIndex(advance(self.startIndex, self.characters.count - suffix.characters.count)) + pluralSuffix
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
  
    - parameter pattern:          The pattern to compare against
    - parameter allowPartial:     Whether we should allow partial matches. If
                                  this is false, the pattern will have to match
                                  against the entire string.
    - returns:                    Whether this string matches the given pattern.
    */
  public func matches(pattern: String, allowPartial: Bool = false) -> Bool {
    let fullPattern = allowPartial ? pattern : "^\(pattern)$"
    let expression: NSRegularExpression
    do {
      expression = try NSRegularExpression(pattern: fullPattern, options: [])
    } catch {
      return false
    }
    let range = NSRange(location: 0, length: self.characters.count)
    let results = expression.numberOfMatchesInString(self, options: [], range: range)
    return results > 0
  }
  
  /**
    This method gets the last component of this string, once it is separated by
    a separator.
  
    If the separator does not occur in the string, this will return the entire
    string.

    - parameter separator:    The string to use as a separator.
    - returns:                The last component
    */
  public func lastComponent(separator separator: String) -> String {
    if let range = self.rangeOfString(separator, options: [.BackwardsSearch], range: nil, locale: nil) {
      return self.substringFromIndex(range.endIndex)
    }
    else {
      return self
    }
  }
}