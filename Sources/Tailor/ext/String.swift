import Foundation

public extension String {
  /** The string with the first character lowercased. */
  public var lowercaseInitial: String {
    get {
      return String(self[self.startIndex]).lowercaseString + self.bridge().substringFromIndex(1)
      
    }
  }
  
  /** The string with the first character capitalized. */
  public var capitalizeInitial: String {
    get {
      return String(self[self.startIndex]).capitalizedString +
        self.bridge().substringFromIndex(1)
      
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
        return self.bridge().substringToIndex(self.characters.count - suffix.characters.count) + pluralSuffix
      }
    }
    return self + "s"
  }
  
  /** Whether this string contains another one. */
  public func contains(other: String) -> Bool {
    return self.bridge().rangeOfString(other).location != NSNotFound
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
    let range = self.bridge().rangeOfString(separator, options: [.BackwardsSearch])
    if range.location != NSNotFound {
      return self.bridge().substringFromIndex(range.location + range.length)
    }
    else {
      return self
    }
  }
  
  /**
    This method gets the full range of the characters in the string.
    */
  public var rangeOfSelf: NSRange {
    return NSMakeRange(0, self.characters.count)
  }
  
  /**
    This method replaces all the characters that are not in an allowed set with
    a replacement string.
    
    - parameter set:          The allowed characters in the result
    - parameter replacement:  The string that should replace the forbidden
                              characters.
    */
  public func stringByEscapingCharacters(set: NSCharacterSet, with replacement: String) -> String {
    var newCharacters = String.UnicodeScalarView()
    newCharacters.reserveCapacity(unicodeScalars.count)
    for character in unicodeScalars {
      let value = character.value
      if value < UInt32(UInt16.max) && set.characterIsMember(UInt16(value)) {
        newCharacters.append(character)
      }
      else {
        newCharacters.appendContentsOf(replacement.unicodeScalars)
      }
    }
    return String(newCharacters)
  }
}