import Foundation

/**
  This validator requires that the value be a number within a certain range.

  If the value does not exist or is not an NSNumber object, it will fail this 
  validation.

  The validator requires one of these additional keys:

  * min: An Int with the minimum permitted value
  * max: An Int with the maximum permitted value

  Both min and max are inclusive. You can provide both values to bound both ends
  of the range.
  */
public class RangeValidator : Validator {
  /**
    This method applies the range validation.

    :param: model   The model object to validate.
    */
  public override func validate(model: Model) {
    switch(model.valueForKey(self.key)) {
    case let number as NSNumber:
      var matched = true
      if let max = self.data["max"] as? Int {
        if number.integerValue > max {
          model.errors.add(key, "must be at most \(max)")
        }
      }
      if let min = self.data["min"] as? Int {
        if number.integerValue < min {
          model.errors.add(key, "must be at least \(min)")
        }
      }
    default:
      model.errors.add(key, "cannot be blank")
    }
  }
}