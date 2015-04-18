import Foundation

/**
  This class represents a model object.

  Model object provide shorthand for getting and setting dynamic Swift
  properties, validations, and error storage.
  */
public class Model {
  //MARK: - Structure
  
  /** The errors that have been set on this object in the validation process. */
  public var errors: ErrorCollection!
  
  public init() {
    self.errors = ErrorCollection(modelType: self.dynamicType)
  }
  
  /** 
    The name of the model.

    This implementation infers it from the class name.
    */
  public class func modelName() -> String {
    var fullName = NSStringFromClass(self)
    if let range = fullName.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil) {
      fullName = fullName.substringFromIndex(advance(range.startIndex, 1))
    }
    return fullName.underscored()
  }
  
  //MARK: - Validations

  /** The validators that will be applied to model objects for this model. */
  public class func validators() -> [Validator] {
    return []
  }
  
  /**
    This method runs all of the validators for this model's type.
  
    :returns:   Whether the object passed all the validations.
    */
  public func validate() -> Bool {
    self.errors.errors = []
    var valid = true
    for validator in self.dynamicType.validators() {
      validator.validate(self)
    }
    return self.errors.isEmpty
  }
  
  //MARK: - Dynamic Properties
  
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
      let translationKey = "record.\(self.modelName()).attributes.\(key.underscored())"
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
}