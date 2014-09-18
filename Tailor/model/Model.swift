import Foundation

/**
  This class represents a model object.

  Model object provide shorthand for getting and setting dynamic Swift
  properties, validations, and error storage.
  */
class Model {
  //MARK - Structure
  
  /** 
    The name of the model.

    This implementation infers it from the class name.
    */
  class func modelName() -> String {
    var fullName = NSStringFromClass(self)
    let range = fullName.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil)
    if range != nil {
      fullName = fullName.substringFromIndex(advance(range!.startIndex, 1))
    }
    return fullName
  }
  
  //MARK - Validations
  
  /** The errors that have been set on this object in the validation process. */
  let errors = ErrorCollection()

  /** The validators that will be applied to model objects for this model. */
  class func validators() -> [Validator] {
    return []
  }
  
  /**
    This method runs all of the validators for this model's type.
  
    :returns:   Whether the object passed all the validations.
    */
  func validate() -> Bool {
    self.errors.errors = [:]
    var valid = true
    for validator in self.dynamicType.validators() {
      validator.validate(self)
    }
    return self.errors.isEmpty()
  }
  
  //MARK - Dynamic Properties
  
  /**
    This method gets the name of a property converted into a human-readable
    name.

    Every capital letter will be interpreted as the beginning of a new word.
    Each word will be capitalized, including the first.
  
    :param: key     The attribute name.
    :returns:       The humanized attribute name.
    */
  class func humanAttributeName(key: String) -> String {
    var result = ""
    for (index, character) in enumerate(key) {
      let string = String(character)
      if index == 0 {
        result += string.capitalizedString
      }
      else {
        if string == string.capitalizedString {
          result += " "
        }
        result += string
      }
    }
    return result
  }

  /**
    This method gets the value for a dynamic property.

    If the property doesn't exist, this will return nil.

    :param: key   The name of the property.
    :returns:     The value.
    */
  func valueForKey(key: String) -> AnyObject? {
    let klass : AnyClass! = object_getClass(self)
    let getter = class_getInstanceMethod(klass, Selector(key))
    if getter != nil {
      return tailorInvokeGetter(self, getter)
    }
    else {
      return nil
    }
  }
  
  /**
    This method sets the value for a dynamic property.
  
    If the property doesn't exist, this will quietly do nothing.
    
    :param: value   The value to set.
    :param: key     The name of the property.
    */
  func setValue(value: Any?, forKey key: String) {
    let capitalName = key.capitalizeInitial
    let setterName = "set" + capitalName + ":"
    let klass : AnyClass! = object_getClass(self)
    let setter = class_getInstanceMethod(klass, Selector(setterName))
    if setter != nil {
      var objectValue : AnyObject? = ""
      
      switch value {
      case let string as String:
        objectValue = string
      case let date as NSDate:
        objectValue = date
      case let int as Int:
        objectValue = NSNumber(integer: int)
      case let double as Double:
        objectValue = NSNumber(double: double)
      case nil:
        objectValue = nil
      default:
        break
      }
      tailorInvokeSetter(self, setter, objectValue)
    }
  }
}