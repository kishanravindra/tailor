/**
  This method represents errors that have occurred in validation.
  */
public class ErrorCollection {
  /**
    A mapping between a key and a list of error descriptions.
    */
  public var errors: [String:[String]] = [:]
  
  /**
    This method adds an error to the collection.

    :param: key           The name of the property with the error.
    :param: description   A description of the error.
    */
  public func add(key: String, _ description: String) {
    var errors = self.errors[key] ?? []
    errors.append(description)
    self.errors[key] = errors
  }
  
  /** Whether this error collection has any errors. */
  public func isEmpty() -> Bool {
    for (key, errors) in self.errors {
      if !errors.isEmpty {
        return false
      }
    }
    return true
  }
}