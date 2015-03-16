import Foundation

/**
  This class represents a filter for sanitizing text.
  */
public class Sanitizer {
  /**
    A mapping of characters to replace.

    The keys are the characters that should be removed, and the values are the
    strings that should replace them.
  
    This implementation returns an empty mapping, but subclasses can override
    it.
    */
  public class func mapping() -> [Character:String] { return [:] }
  
  /**
    This method initializes a sanitizer.
    */
  public required init() {
  }
  
  /**
    This method determines if a sanitized text wrapper has been sanitized with
    this sanitizer.
    */
  public class func isSanitized(text: SanitizedText) -> Bool {
    for sanitizer in text.sanitizers {
      if NSStringFromClass(sanitizer) == NSStringFromClass(self) {
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

    :params: string   The text to sanitize.
    :returns:         The sanitized text.
    */
  public func sanitizeString(string: String) -> String {
    var sanitized = ""
    for character in string {
      var result = self.dynamicType.mapping()[character] ?? String(character)
      sanitized += result
    }
    return sanitized
  }
  
  /**
    This method takes sanitized text and applies another round of sanitization
    to it.

    If the text has already been sanitized with this sanitizer, it will do
    nothing.

    :param: text  The sanitized text wrapper
    :returns:     The sanitized text wrapper for the new level of sanitization.
    */
  public func sanitize(text: SanitizedText) -> SanitizedText {
    if self.dynamicType.isSanitized(text) {
      return text
    }
    return SanitizedText(text: self.sanitizeString(text.text), sanitizers: text.sanitizers + [self.dynamicType])
  }
  
  /**
    This method puts a string into a sanitized text that says that this
    sanitizer has been applied, but does not run any filters on it.
    
    Use this method with caution, and only when are absolutely certain of the
    contents of the string.
    
    :param: string    The string to put in the sanitized text wrapper.
    :returns:         The sanitized text wrapper.
  */
  public func accept(string: String) -> SanitizedText {
    return SanitizedText(text: string, sanitizers: [self.dynamicType])
  }
}