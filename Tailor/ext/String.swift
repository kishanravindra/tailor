import Foundation

extension String {
  /** The string with the first character lowercased. */
  var lowercaseInitial: String {
    get {
      return String(self[self.startIndex]).lowercaseString +
        self.substringFromIndex(advance(self.startIndex, 1))
      
    }
  }
  
  /** The string with the first character capitalized. */
  var capitalizeInitial: String {
    get {
      return String(self[self.startIndex]).capitalizedString +
        self.substringFromIndex(advance(self.startIndex, 1))
      
    }
  }
}