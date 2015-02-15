import Foundation


/**
  This method removes the nil values from an array.

  :param: array   The original array
  :returns:       The array with the nil values removed.
  */
public func removeNils<T>(array: Array<T?>) -> Array<T> {
  var results : [T] = []
  for element in array {
    if element != nil {
      results.append(element!)
    }
  }
  return results
}