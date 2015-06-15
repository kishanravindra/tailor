import Foundation

/**
  This method merges two dictionaries.

  If a given key has values in both the left and right-hand sides, the
  right-hand side will take precedence.

  - parameter lhs:   The first dictionary
  - parameter rhs:   The second dictionary
  - returns:     The merged dictionary.
  */
public func merge<KeyType,ValueType>(lhs: Dictionary<KeyType, ValueType>, _ rhs: Dictionary<KeyType,ValueType>) -> Dictionary<KeyType,ValueType> {
  var result = Dictionary<KeyType,ValueType>()
  for (key,value) in lhs {
    result[key] = value
  }
  for (key,value) in rhs {
    result[key] = value
  }
  return result
}