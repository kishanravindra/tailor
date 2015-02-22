import Foundation

/**
  This validator requires that the value be a number within a certain range.

  If the value does not exist or is not an NSNumber object, it will fail this 
  validation.

  The validator requires one of these additional fields:

  * min: An Int with the minimum permitted value
  * max: An Int with the maximum permitted value

  Both min and max are inclusive. You can provide both values to bound both ends
  of the range.
  */
public class RangeValidator : Validator {
  /** The minimum value that this validator will accept. */
  let min: Int?
  
  /** The maximum value that this validator will accept. */
  let max: Int?
  
  /**
    This method creates a range validator.

    :param: key   The name of the field that this will validate.
    :param: min   The minimum value that this will accept.
    :param: max   The maximum value that this will accept.
    */
  public required init(key: String, min: Int? = nil, max: Int? = nil) {
    self.min = min
    self.max = max
    super.init(key: key)
  }

  /**
    This method creates a range validator.
  
    This initializer doesn't set a minimum or maximum value, which means that it
    will only check that the value is present and is a number.

    :param: key   The name of the field that this will validate.
    */
  public required init(key: String) {
    self.min = nil
    self.max = nil
    super.init(key: key)
  }
  
  /**
    This method applies the range validation.

    :param: model   The model object to validate.
    */
  public override func validate(model: Model) {
    switch(model.valueForKey(self.key)) {
    case let number as NSNumber:
      var matched = true
      if max != nil {
        if number.integerValue > max! {
          model.errors.add(key, "must be at most \(max!)")
        }
      }
      if min != nil {
        if number.integerValue < min! {
          model.errors.add(key, "must be at least \(min!)")
        }
      }
    case nil:
      model.errors.add(key, "cannot be blank")
    default:
      model.errors.add(key, "must be a number")
    }
  }
}