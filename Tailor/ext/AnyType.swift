/**
  This function gets the name of a type.
  
  - parameter type:   The type we want the name of.
  - returns:          The name of the type.
  */
public func typeName(type: Any.Type) -> String {
  let description = Mirror(reflecting: type).description
  let range = advance(description.startIndex, 11)...advance(description.endIndex, -6)
  return description.substringWithRange(range)
}