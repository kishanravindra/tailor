/**
  This method is the base class for validators.

  A validator encapsulates information about a validation that is run on a
  property on a model object.

  This class performs no validations. Subclasses must define the validation
  rules.
  */
class Validator {
  /** The name of the property the validator operates on. */
  let key: String
  
  /** Additional information that is specific to the type of validation */
  let data: [String:Any]
  
  /**
    This method initializes a validator.

    :param: key   The name of the property the validator operates on.
    :param: data  Additional information that is specific to the type of
                  validation.
    */
  required init(key: String, data: [String: Any] = [:]) {
    self.key = key
    self.data = data
  }

  /**
    This method applies the validations to a model object.

    This implementation does nothing. Subclasses are responsible for applying
    their validation rules and setting errors on the model. If no errors are
    set on the model, then the model is considered to have passed the
    validation.

    :param: model     The model object to validate.
    */
  func validate(model: Model) {}
}