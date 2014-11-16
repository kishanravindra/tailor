import Foundation

/**
  This class represents a model object.

  Model object provide shorthand for getting and setting dynamic Swift
  properties, validations, and error storage.
  */
public class Model {
  //MARK - Structure
  
  /** 
    The name of the model.

    This implementation infers it from the class name.
    */
  public class func modelName() -> String {
    var fullName = NSStringFromClass(self)
    let range = fullName.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil)
    if range != nil {
      fullName = fullName.substringFromIndex(advance(range!.startIndex, 1))
    }
    return fullName.underscored()
  }
  
  //MARK - Validations
  
  /** The errors that have been set on this object in the validation process. */
  public let errors = ErrorCollection()

  /** The validators that will be applied to model objects for this model. */
  public class func validators() -> [Validator] {
    return []
  }
  
  /**
    This method runs all of the validators for this model's type.
  
    :returns:   Whether the object passed all the validations.
    */
  public func validate() -> Bool {
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

    It will first try to use a localization to fetch the name. The key for the
    translation will be based on the model name and key name. For the
    paymentAmount attributes on a PurchaseOrder model, it will be
    record.purchase_order.attributes.payment_amount.
  
    If it cannot get the translation, or a localization is not provided, it will
    generate a label based on the attributes name. Every capital letter will be
    interpreted as the beginning of a new word.
  
    :param: key           The attribute name.
    :param: localization  The localization to get the name.
    :param: capitalize    Whether we should capitalize the name.
    :returns:             The humanized attribute name.
    */
  public class func humanAttributeName(key: String, localization: Localization? = nil, capitalize: Bool = false) -> String {
    var result = ""
    
    if localization != nil {
      let translationKey = "record.\(self.modelName().underscored()).attributes.\(key.underscored())"
      let translation = localization?.fetch(translationKey)
      if translation != nil {
        return capitalize ? translation!.capitalizedString : translation!
      }
    }
    
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
    return capitalize ? result : result.lowercaseString
  }

  /**
    This method gets the value for a dynamic property.

    If the property doesn't exist, this will return nil.

    :param: key   The name of the property.
    :returns:     The value.
    */
  public func valueForKey(key: String) -> AnyObject? {
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
  public func setValue(value: Any?, forKey key: String) {
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
      case let object as NSObject:
        objectValue = object
      case nil:
        objectValue = nil
      default:
        break
      }
      tailorInvokeSetter(self, setter, objectValue)
    }
  }
}