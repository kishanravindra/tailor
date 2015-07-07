/**
  This enum represents a simple value that can be natively represented in JSON.
  */
public enum JsonPrimitive {
  /** A JSON String. */
  case String(Swift.String)
  
  /** A JSON Array, containing other JSON primitives. */
  case Array([JsonPrimitive])
  
  /** A JSON dictionary, mapping Swift strings to other JSON primitives. */
  case Dictionary([Swift.String: JsonPrimitive])
  
  //MARK: - Converting to JSON
  
  /**
    This method gets the object that this enum case wraps around.

    This is designed to be fed into the methods in NSJSONSerialization, though
    the return value may not be a valid JSON object by that class's rules.
    */
  public var toFoundationJsonObject: AnyObject {
    switch(self) {
    case let String(string):
      return string
    case let Array(array):
      return array.map { $0.toFoundationJsonObject }
    case let Dictionary(dictionary):
      var results : [Swift.String:AnyObject] = [:]
      for (key,value) in dictionary {
        results[key] = value.toFoundationJsonObject
      }
      return results
    }
  }
  
  /**
    This method gets the encoded JSON data.

    This can throw a `JsonConversionError`, or anything that
    `NSJSONSerialization.dataWithJSONObject can throw.
    */
  public func jsonData() throws -> NSData {
    let object = self.toFoundationJsonObject
    if !NSJSONSerialization.isValidJSONObject(object) {
      throw JsonConversionError.NotValidJsonObject
    }
    return try NSJSONSerialization.dataWithJSONObject(object, options: [])
  }
}

/**
  This enum holds errors that can occur when converting a data structure into
  JSON.
  */
public enum JsonConversionError: ErrorType {
  /**
    This error is thrown when trying to get JSON data from a foundation object
    that is not a valid JSON object, per the rules in NSJSONSerialization.
    */
  case NotValidJsonObject
}