/**
  This enum holds errors that can occur when parsing JSON data, or extracting
  values from a JSON primitive.
  */
public enum JsonParsingError : ErrorType, Equatable {
  /**
    This error occurs when trying to initialize a primitive with an
    unsupported type, or read into an unsupported type.
    */
  case UnsupportedType(Any.Type)
  
  /**
    This error occurs when trying to read a value from a JSON primitive when the
    primitive is not of the desired type.
  
    This includes a field name so that if it occurs deep in parsing a nested
    JSON data structure, we can build up the field name to tell where in the
    dictionary the problem was.
  
    - parameter field:    The name of the field we are trying to read.
    - parameter type:     The type that the caller wanted.
    - parameter caseType: The type that the JSON primitive wraps around.
    */
  case WrongFieldType(field: String, type: Any.Type, caseType: Any.Type)
  
  /**
    This error occurs when trying to read a field from a JSON dictionary that is
    not present.

    - parameter field:  The name of the field that we are trying to read.
    */
  case MissingField(field: String)
}

/**
  This method determines if two parsing errors are equal.

  - param lhs:    The left-hand side of the operator.
  - param rhs:    The right-hand side of the operator.
  - returns:      Whether the two errors are equal.
  */
public func ==(lhs: JsonParsingError, rhs: JsonParsingError) -> Bool {
  switch(lhs) {
  case let .UnsupportedType(type1):
    if case let .UnsupportedType(type2) = rhs {
      return type1 == type2
    }
  case let .WrongFieldType(field: field1, type: type1, caseType: caseType1):
    if case let .WrongFieldType(field: field2, type: type2, caseType: caseType2) = rhs {
      return field1 == field2 && type1 == type2 && caseType1 == caseType2
    }
  case let .MissingField(field: field1):
    if case let .MissingField(field: field2) = rhs {
      return field1 == field2
    }
  }
  return false
}

/**
  This enum holds errors that can occur when converting a data structure into
  JSON.
  */
public enum JsonConversionError: ErrorType, Equatable {
  /**
  This error is thrown when trying to get JSON data from a foundation object
  that is not a valid JSON object, per the rules in NSJSONSerialization.
  */
  case NotValidJsonObject
}

