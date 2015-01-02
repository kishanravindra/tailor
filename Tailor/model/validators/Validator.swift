/**
  This method is the base class for validators.

  A validator encapsulates information about a validation that is run on a
  property on a model object.

  This class performs no validations. Subclasses must define the validation
  rules.
  */
public class Validator {
  /** The name of the property the validator operates on. */
  public let key: String
  
  /**
    This method initializes a validator.

    :param: key   The name of the property the validator operates on.
    :param: data  Additional information that is specific to the type of
                  validation.
    */
  public required init(key: String) {
    self.key = key
  }

  /**
    This method applies the validations to a model object.

    This implementation does nothing. Subclasses are responsible for applying
    their validation rules and setting errors on the model. If no errors are
    set on the model, then the model is considered to have passed the
    validation.

    :param: model     The model object to validate.
    */
  public func validate(model: Model) {}
}