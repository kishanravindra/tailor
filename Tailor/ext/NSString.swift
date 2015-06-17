import Foundation

public extension String {
  /**
    This method converts a string to camel case.

    - parameter capitalize:     Whether we should capitalize the first letter.
    - returns:                  The camel-cased string.
    */
  public func camelCase(capitalize capitalize: Bool = false) -> String {
    let result = NSMutableString()
    var lastWasUnderscore = false
    
    for character in self.characters {
      var newCharacter = String(character)
      if lastWasUnderscore || result.length == 0 && capitalize {
        newCharacter = newCharacter.capitalizedString
      }
      lastWasUnderscore = newCharacter == "_"
      if lastWasUnderscore {
        newCharacter = ""
      }
      result.appendString(newCharacter)
    }
    return result as String
  }
  
  /**
    This method converts a string from camel case to snake case.

    - returns: The converted string.
    */
  public func underscored() -> String {
    let result = NSMutableString()
    
    let alnumSet = NSCharacterSet.alphanumericCharacterSet()
    var lastWasAlnum = false
    for character in self.characters {
      let newCharacter = String(character)
      let lowercase = newCharacter.lowercaseString
      if lowercase != newCharacter && lastWasAlnum {
        result.appendString("_")
      }
      result.appendString(lowercase)
      
      lastWasAlnum = newCharacter.rangeOfCharacterFromSet(alnumSet) != nil
    }
    return result as String
  }
}