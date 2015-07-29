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
  
  /**
    This method runs a block and adds a prefix to the field for any parsing
    errors that get thrown by the block.

    The purpose of this is to make it easier to generate errors for nested
    dictionaries. With this method, you can have a subroutine process a
    lower-level dictionary, and add a key path to its errors as you pass them
    up the call chain. The top-level caller can then report an error that has
    a full path down to where the error occurred.

    - parameter prefix:   The prefix to add to the errors.
    - parameter block:    The block to run
    - returns:            The result of the block.
    */
  public static func withFieldPrefix<T>(prefix: String, block: Void throws->T) throws -> T {
    do {
      return try block()
    }
    catch JsonParsingError.WrongFieldType(field: let field, type: let type, caseType: let caseType) {
      throw JsonParsingError.WrongFieldType(field: "\(prefix).\(field)", type: type, caseType: caseType)
    }
    catch JsonParsingError.MissingField(field: let field) {
      throw JsonParsingError.MissingField(field: "\(prefix).\(field)")
    }
    catch let e {
      throw e
    }
  }
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

