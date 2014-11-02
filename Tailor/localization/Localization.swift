import Foundation

/**
  This class represents a source of localized content.
  */
public class Localization {
  /** The locale for the content this source provides. */
  public let locale : String
  
  /** A mapping of keys to localized strings. */
  let strings: [String:String]
  
  /**
    This method creates a content source.

    :param: locale    The locale for the content.
    */
  public init(locale: String) {
    self.locale = locale
    let config = Application.sharedApplication().configFromFile("strings")[locale] as NSDictionary?
    self.strings = Localization.flattenDictionary(config ?? NSDictionary())
  }
  
  /**
    This method gets the localized content for a key.

    :param: key   The key for the content
    :returns:     The content.
    */
  public func fetch(key: String) -> String? {
    return self.strings[key]
  }
  
  /**
    This method takes a dictionary and returns a flattened dictionary of
    strings.

    If a key is mapped to another dictionary, the key will be combined with the
    entries in that dictionary to produce a single key with the format key1.key2

    :param: dictionary    The dictionary to flatten.
    :returns:             The flattened dictionary.
    */
  public class func flattenDictionary(dictionary: NSDictionary) -> [String:String] {
    var results = [String:String]()
    for (key,value) in dictionary {
      let stringKey = key as String
      switch(value) {
      case let string as String:
        results[stringKey] = string
      case let nestedDictionary as NSDictionary:
        for (nestedKey, nestedValue) in self.flattenDictionary(nestedDictionary) {
          results["\(stringKey).\(nestedKey)"] = nestedValue
        }
      default:
        continue
      }
    }
    return results
  }
}