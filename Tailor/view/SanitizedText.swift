import Foundation

/**
  This struct provides a wrapper around text that specifies what filters have
  been applied to sanitize it.
  */
public struct SanitizedText : StringLiteralConvertible {
  public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
  
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
  public init(unicodeScalarLiteral value: StringLiteralType) {
    self.init(text: value, sanitizers: [])
  }
  
  /**
    This initializer creates sanitized text from a string literal.
    - parameter value:   The string literal value.
  */
  public init(stringLiteral value: StringLiteralType) {
    self.init(text: value, sanitizers: [])
  }
  
  /**
    This initializer creates sanitized text from a string literal.
    - parameter value:   The string literal value.
  */
  public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
    self.init(text: value, sanitizers: [])
  }
}