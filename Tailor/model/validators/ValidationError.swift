/**
  This class represents a validation error that has been added to a model
  object.
  */
public struct ValidationError: Equatable {
  /**
    The type of model the error is for. This is used for translating error
    messages.
    */
  public let modelType: Model.Type
  
  /**
    The key that the error is on.
    */
  public let key: String
  
  /**
    The identifier for the error message. This should be something that can be
    put into a translation key.
    */
  public let message: String
  
  /**
    Additional data about the specifics of the error. This will be interpolated
    into the full error message.
    */
  public let data: [String:String]
  
  /**
    This method gets the localized description for an error message.
  
    This will look for the content using the following keys, in order:
  
    * (model_name).errors.(key).(message)
    * (model_name).errors.(message)
    * model.errors.(key).(message)
    * model.errors.(message)
  
    If it cannot find content for any of those keys, it will return the raw
    message.

    :param: localization    The localization to use to fetch the content.
    :returns:               The description
    */
  public func localize(localization: Localization) -> String {
    var modelName = self.modelType.modelName()
    var message = self.message.underscored()
    var key = self.key.underscored()
    let keys = [
      "\(modelName).errors.\(key).\(message)",
      "\(modelName).errors.\(message)",
      "model.errors.\(key).\(message)",
      "model.errors.\(message)"
    ]
    for key in keys {
      if let result = localization.fetch(key, interpolations: self.data) {
        return result
      }
    }
    return self.message
  }
}

/**
  This function determines if two validation errors are the same.
  */
public func ==(lhs: ValidationError, rhs: ValidationError) -> Bool {
  return lhs.key == rhs.key && lhs.message == rhs.message && lhs.data == rhs.data
}
