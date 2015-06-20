import Foundation

/**
  This class represents a filter for sanitizing text.
  */
public struct Sanitizer: Equatable {
  /**
    The characters that the sanitizer replaces.
    */
  public let mapping: [Character: String]
  
  /**
    This method initializes a sanitizer.
  
    - parameter mapping:   The characters that the sanitizer replaces.
    */
  public init(_ mapping: [Character: String]) {
    self.mapping = mapping
  }
  
  /**
    This method determines if a sanitized text wrapper has been sanitized with
    this sanitizer.
    */
  public func isSanitized(text: SanitizedText) -> Bool {
    for sanitizer in text.sanitizers {
      if sanitizer == self {
        return true
      }
    }
    return false
  }
  
  /**
    This method applies this sanitizer's filters to a string.

    Subclasses can generally provide their filters by setting the mapping
    instance variable, but they can also override this method if they need more
    complicated filters.

    - parameter string:   The text to sanitize.
    - returns:            The sanitized text.
    */
  public func sanitizeString(string: String) -> String {
    var sanitized = ""
    for character in string.characters {
      let result = self.mapping[character] ?? String(character)
      sanitized += result
    }
    return sanitized
  }
  
  /**
    This method takes sanitized text and applies another round of sanitization
    to it.

    If the text has already been sanitized with this sanitizer, it will do
    nothing.

    - parameter text:   The sanitized text wrapper
    - returns:          The sanitized text wrapper for the new level of
                        sanitization.
    */
  public func sanitize(text: SanitizedText) -> SanitizedText {
    if self.isSanitized(text) {
      return text
    }
    return SanitizedText(text: self.sanitizeString(text.text), sanitizers: text.sanitizers + [self])
  }
  
  /**
    This method puts a string into a sanitized text that says that this
    sanitizer has been applied, but does not run any filters on it.
    
    Use this method with caution, and only when are absolutely certain of the
    contents of the string.
    
    - parameter string:     The string to put in the sanitized text wrapper.
    - returns:              The sanitized text wrapper.
  */
  public func accept(string: String) -> SanitizedText {
    return SanitizedText(text: string, sanitizers: [self])
  }
  
  //MARK: - Built-in Sanitizers
  
  /** A sanitizer for sanitizing HTML text. */
  public static var htmlSanitizer : Sanitizer { return Sanitizer([
    "<": "&lt;",
    ">": "&gt;",
    "&": "&amp;",
    "\"": "&quot;",
    "'": "&#39;"
    ])
  }
  
  /** A sanitizer for sanitizing SQL strings. */
  public static var sqlSanitizer: Sanitizer { return Sanitizer([
    "\\": "\\\\",
    "\"": "\\\"",
    "'": "\\'"
    ]) }

}

/**
  This function determines if two sanitizers are equal.

  The sanitizers will be equal if they have the same mapping.

  - parameter lhs:    The left hand side of the operator
  - parameter rhs:    The right hand side of the operator
  - returns:          Whether the two sanitizers are equal.
  */
public func ==(lhs: Sanitizer, rhs: Sanitizer) -> Bool {
  return lhs.mapping == rhs.mapping
}