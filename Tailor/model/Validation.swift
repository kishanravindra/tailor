/**
  This struct runs and collects validations on a model object.

  You can construct a new validation with no errors, and then run the `validate`
  methods in a chain to run checks and collect the errors. Each call to a
  `validate` method will return a new validation; if the validation failed, that
  new validation will have a new error in its collection, as well as all the
  errors from the previous validation.
  */
public struct Validation<ModelType: Model> {
  /** The validation errors that we have collected. */
  public let errors: [ValidationError]
  
  /**
    This method initializes a validation with a list of validation errors.
  
    You will generally want to initialize your validations with no errors, and
    then use the validate methods to collect them.
    
    :param: errors    The validation errors that we are collecting.
    */
  public init(_ errors: [ValidationError] = []) {
    self.errors = errors
  }
  
  //MARK: - Running Validations
  
  /**
    This method builds a new validation that has all the errors from this
    validation's list, with a single error added.

    :param: key       The key for the field that has the error
    :param: message   The message describing the error
    :param: data      The data to interpolate in the localized error message
    :returns:         The validation with this new error
    */
  public func withError(key: String, _ message: String, data: [String:String] = [:]) -> Validation<ModelType> {
    return Validation<ModelType>(self.errors + [ValidationError(
      modelType: ModelType.self,
      key: key,
      message: message,
      data: data
      )])
  }
  
  /**
    This method validates that a value is present on the model.

    :param: key   The name of the field
    :param value  The value for the field.
    :returns:     The new validation with the error added.
    */
  public func validate(presenceOf key: String, _ value: Any?) -> Validation<ModelType> {
    if value == nil {
      return withError(key, "blank")
    }
    
    if let string = value as? String {
      if string.isEmpty {
        return withError(key, "blank")
      }
    }
    
    return self
  }
  
  /**
    This method validates that a value is in an interval.

    :param: key     The name of the field.
    :param: value   The value of the field
    :param: bounds  The interval that the value must be within
    :returns        The new validation with the error added.
    */
  public func validate<T: IntervalType where T.Bound : Printable>(key: String, _ value: T.Bound, inBounds bounds: T) -> Validation<ModelType> {
    if !bounds.contains(value) {
      if value <= bounds.start {
        return withError(key, "tooLow", data: ["min": bounds.start.description])
      }
      if value >= bounds.end {
        return withError(key, "tooHigh", data: ["max": bounds.end.description])
      }
    }
    return self
  }
  
  /**
    This method validates a model by running a block.
    
    The block must return a list of errors, expresed as a 3-tuple containing:
    
    * The name of the field with the error
    * The error message
    * A dictionary of additional data to give to the validation error
  
    :param: block   The block that will run the checks
    :returns:       The new validation with the errors added.
    */
  public func validate(block: ()->[(String,String,[String:String])]) -> Validation<ModelType> {
    let newErrors = block().map {
      ValidationError(modelType: ModelType.self, key: $0.0, message: $0.1, data: $0.2)
    }
    return Validation<ModelType>(self.errors + newErrors)
  }
  
  /**
    This method validates that set of fields on a record are unique.

    This must only be run on record types. If the model type for the validation
    is not a record, the behavior of this method is not defined.

    The field names for this validation must be the names of the columns in the
    database. If this is validating more than one field, the key for the
    validation error will be all of the field names, in alphabetical order,
    combined with an underscore. For instance, if you are validating the fields
    `first_name` and `last_name`, the error would have the key
    `first_name_last_name`.
    
    This will return an error whenever there is any value with all of the values
    in the dictionary for the field names in the dictionary. If an id is
    provided, this will ignore any records with that id. If you are validating
    a persisted record, you must provide the id. If you do not, the validation
    will likely find the record itself as a duplicate and give a false error.

    :param: fields    The fields that must be unique.
    :param: id        The id of the record that we are validating.
    :returns:         The new validation with the error added.
    */
  public func validate(uniquenessOf fields: [String: DatabaseValueConvertible?], id: Int?) -> Validation<ModelType> {
    let recordType: Record.Type! = ModelType.self as? Record.Type
    if recordType == nil {
      return self
    }
    
    if fields.isEmpty {
      return self
    }
    
    var query = "SELECT * FROM \(recordType.tableName()) WHERE "
    
    var parameterString = ""
    var parameters = [DatabaseValue]()
    
    for (key,value) in fields {
      if !parameterString.isEmpty {
        parameterString += " AND "
      }
      let sanitizedKey = SqlSanitizer().sanitizeString(key)
      
      if value == nil {
        parameterString += "\(sanitizedKey) IS NULL"
      }
      else {
        parameterString += "\(sanitizedKey)=?"
        parameters.append(value!.databaseValue)
      }
    }
    
    if id != nil {
      parameterString += " AND id!=?"
      parameters.append(id!.databaseValue)
    }
    
    query += parameterString
    
    let duplicates = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)

    if !duplicates.isEmpty {
      let compositeKey = join("_", sorted(fields.keys))
      return withError(compositeKey, "taken")
    }
    return self
  }
  
  //MARK: - Error Access
  
  /**
    This method gets the validation errors on a given key.

    :param: key   The key for the validation errors
    :returns:     The validation errors that occurred on that key.
    */
  public subscript(key: String)->[ValidationError] {
    return self.errors.filter { $0.key == key }
  }
  
  /**
    This method determines if this validation has passed all the checks.
    */
  public var valid: Bool {
    return self.errors.isEmpty
  }
}