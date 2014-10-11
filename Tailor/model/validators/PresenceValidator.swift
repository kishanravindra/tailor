import Foundation

/**
  This validator provides a validation that a value is present for a key.

  If the value is nil, or is an empty String, it will fail this validation.

  If the value is a non-String type, then merely being present will pass the
  validation.
  */
public class PresenceValidator : Validator {
  /**
    This method validates that a model object passes the validator.

    :param: model   The model object to validate.
    */
  public override func validate(model: Model) {
    let value: AnyObject? = model.valueForKey(key)
    var present = true
    if value == nil {
      present = false
    }
    else {
      switch(value) {
      case let string as String:
        present = !string.isEmpty
      default:
        break
      }
    }
    
    if !present {
      model.errors.add(key, "cannot be blank")
    }
  }
}