import Foundation

/**
  This method merges two dictionaries.

  If a given key has values in both the left and right-hand sides, the
  right-hand side will take precedence.

  - parameter lhs:    The first dictionary
  - parameter rhs:    The second dictionary
  - returns:          The merged dictionary.
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

public extension Dictionary {
  /**
    This method creates a new dictionary with this dictionary's keys mapped
    to the results of calling a transform function on their corresponding
    values.

    - parameter transform:    The transform function
    - returns:                The new dictionary.
    */
  public func map<T>(@noescape transform: (Value) -> T) -> [Key:T] {
    var result = [Key:T]()
    for (key,value) in self {
      result[key] = transform(value)
    }
    return result
  }
  
  /**
    This method creates a new dictionary with this dictionary's keys mapped
    to the results of calling a transform function on their corresponding
    values.

    - parameter transform:    The transform function
    - returns:                The new dictionary.
    */
  public func map<T>(@noescape transform: (Value) throws -> T) rethrows -> [Key:T] {
    var result = [Key:T]()
    for (key,value) in self {
      result[key] = try transform(value)
    }
    return result
  }

}