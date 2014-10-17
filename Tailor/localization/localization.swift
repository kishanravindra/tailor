import Foundation

/**
  This class represents a source of localized content.
  */
public class Localization {
  /** The locale for the content this source provides. */
  let locale : String
  
  /** A mapping of keys to localized strings. */
  let strings: [String:String]
  
  /**
    This method creates a content source.

    :param: locale
      The locale for the content.
    */
  public init(locale: String) {
    self.locale = locale
    let strings = Application.sharedApplication().configFromFile("strings")[locale] as NSDictionary?
    self.strings = (strings ?? NSDictionary()) as [String:String]
  }
  
  /**
    This method gets the localized content for a key.

    :param: key
      The key for the content
    
    :returns:
      The content.
    */
  public func fetch(key: String) -> String? {
    return self.strings[key]
  }
}