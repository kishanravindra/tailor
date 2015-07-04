import Foundation


/**
  This method removes the nil values from an array.

  - parameter array:    The original array
  - returns:            The array with the nil values removed.
  */
public func removeNils<T>(array: Array<T?>) -> Array<T> {
  var results : [T] = []
  for element in array {
    if let element = element {
      results.append(element)
    }
  }
  return results
}