import Foundation

/**
  This struct provides a wrapper around text that specifies what filters have
  been applied to sanitize it.
  */
public struct SanitizedText : StringLiteralConvertible, Equatable {
  /** The text itself. */
  public let text: String
  
  /** The sanitizers that have been applied to the text. */
  public let sanitizers: [Sanitizer]
  
  /**
    This initializer creates a sanitized text wrapper from the sanitized text.

    - parameter text:          The sanitized text
    - parameter sanitizers:    The sanitizers that have been applied.
    */
  public init(text: String, sanitizers: [Sanitizer]) {
    self.text = text
    self.sanitizers = sanitizers
  }
  
  /**
    This initializer creates sanitized text from a string literal.
    - parameter value:   The string literal value.
  */
  public init(stringLiteral value: String) {
    self.init(text: value, sanitizers: [])
  }
  
  /**
    This initializer creates sanitized text from a string literal.
    - parameter value:   The string literal value.
  */
  public init(extendedGraphemeClusterLiteral value: String) {
    self.init(stringLiteral: value)
  }
  
  /**
    This initializer creates sanitized text from a string literal.
    - parameter value:   The string literal value.
    */
  public init(unicodeScalarLiteral value: String) {
    self.init(stringLiteral: value)
  }
}

/**
  This function determines if two sanitized text strings are equal.

  The sanitizers will be equal if they have the same text and sanitizer list.

  - parameter lhs:    The left hand side of the operator
  - parameter rhs:    The right hand side of the operator
  - returns:          Whether the two strings are equal.
  */
public func ==(lhs: SanitizedText, rhs: SanitizedText) -> Bool {
  return lhs.text == rhs.text &&
    lhs.sanitizers == rhs.sanitizers
}