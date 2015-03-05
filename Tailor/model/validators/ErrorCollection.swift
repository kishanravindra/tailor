/**
  This method represents errors that have occurred in validation.
  */
public struct ErrorCollection {
  /**
    The model this collection is for.
    */
  public let modelType: Model.Type
  
  /**
    A mapping between a key and a list of error descriptions.
    */
  public var errors: [ValidationError] = []
  
  /**
    This method adds an error to the collection.

    :param: key           The name of the property with the error.
    :param: message       The message indentifying the error. This should be a
                          symbol that can be put into part of a localization
                          key.
    :param: data          Additional data about the error that can be put into
                          the translation for the error.
    */
  public mutating func add(key: String, _ message: String, data: [String:String] = [:]) {
    self.errors.append(ValidationError(modelType: self.modelType, key: key, message: message, data: data))
  }
  
  /** Whether this error collection has any errors. */
  public var isEmpty: Bool {
    return self.errors.isEmpty
  }
  
  /**
    This method gets the errors that have a particular key.
    
    :param: key   The key we are looking for.
    :returns:     The errors with that key.
    */
  public subscript(key: String) -> [ValidationError] {
    return self.errors.filter { $0.key == key }
  }
}