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
}