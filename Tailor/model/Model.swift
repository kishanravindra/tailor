import Foundation

/**
  This protocol represents a domain model object.

  It provides convenience methods for getting model and attribute names, which
  is useful in form building.

  These methods all have default implementations based on the name of the class,
  but implementing types can provide custom implementations as well.
  */
public protocol ModelType {
  /**
    This method gets the name of a model
    */
  static func modelName() -> String
  
  /**
    This method gets the name of a property converted into a human-readable
    name.
  
    The default implementation will first try to use a localization to fetch the
    name. The key for the translation will be based on the model name and key
    name. For the paymentAmount attributes on a PurchaseOrder model, it will be
    record.purchase_order.attributes.payment_amount.
  
    If it cannot get the translation, or a localization is not provided, it will
    generate a label based on the attribute name. Every capital letter will be
    interpreted as the beginning of a new word.
  
    - parameter key:            The attribute name.
    - parameter localization:   The localization to get the name.
    - parameter capitalize:     Whether we should capitalize the name.
    - returns:                  The humanized attribute name.
    */
  static func attributeName(key: String, localization: LocalizationSource?, capitalize: Bool) -> String
}

public extension ModelType {
  public static func modelName() -> String {
    var fullName = String(reflecting: self)
    if let range = fullName.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil) {
      fullName = fullName.substringFromIndex(advance(range.startIndex, 1))
    }
    return fullName.underscored()
  }
  
  
  public static func attributeName(key: String, localization: LocalizationSource? = nil, capitalize: Bool = false) -> String {
    var result = ""
    
    if localization != nil {
      let translationKey = "record.\(modelName()).attributes.\(key.underscored())"
      if let translation = localization?.fetch(translationKey) {
        return capitalize ? translation.capitalizedString : translation
      }
    }
    
    for (index, character) in key.characters.enumerate() {
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

/**
  This method gets the name of a model, based on the class.

  This method is deprecated. You should have classes implement the `ModelType`
  protocol and use the static methods in that protocol instead.

  - returns:   The model name.
  */
@available(*, deprecated, message="Use the ModelType protocol instead") public func modelName(klass: Any.Type) -> String {
  var fullName = String(reflecting: klass)
  if let range = fullName.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil) {
    fullName = fullName.substringFromIndex(advance(range.startIndex, 1))
  }
  return fullName.underscored()
}
  
/**
  This method gets the name of a property converted into a human-readable
  name.
  
  It will first try to use a localization to fetch the name. The key for the
  translation will be based on the model name and key name. For the
  paymentAmount attributes on a PurchaseOrder model, it will be
  record.purchase_order.attributes.payment_amount.
  
  If it cannot get the translation, or a localization is not provided, it will
  generate a label based on the attribute name. Every capital letter will be
  interpreted as the beginning of a new word.
  
  - parameter modelName:      The name of the model that the attribute is on.
  - parameter key:            The attribute name.
  - parameter localization:   The localization to get the name.
  - parameter capitalize:     Whether we should capitalize the name.
  - returns:                  The humanized attribute name.
  */
@available(*, deprecated, message="Use the ModelType protocol instead") public func modelAttributeName(modelName: String, key: String, localization: LocalizationSource? = nil, capitalize: Bool = false) -> String {
  
  var result = ""
  
  if localization != nil {
    let translationKey = "record.\(modelName).attributes.\(key.underscored())"
    if let translation = localization?.fetch(translationKey) {
      return capitalize ? translation.capitalizedString : translation
    }
  }
  
  for (index, character) in key.characters.enumerate() {
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