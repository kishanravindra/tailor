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
        return self.substringToIndex(advance(self.startIndex, countElements(self) - countElements(suffix))) + pluralSuffix
      }
    }
    return self + "s"
  }
  
  /** Whether this string contains another one. */
  public func contains(other: String) -> Bool {
    return self.rangeOfString(other) != nil
  }
}