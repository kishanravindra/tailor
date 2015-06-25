

/**
  This class provides a source of localizations that are taken from a strings
  property list.
  */
public final class PropertyListLocalization: LocalizationSource {
  /**
    The locale that we are getting content in.
    */
  public let locale: String
  
  /**
    This method initializes a localization.

    - parameter locale:   The locale that we are getting content in.
    */
  public init(locale: String) {
    self.locale = locale
  }
  
  /**
    This method gets the localized content for a key.
    
    - parameter key:    The key for the content
    - returns:          The content.
    */
  public func fetch(key: String, inLocale locale: String) -> String? {
    return Application.sharedApplication().configuration.fetch("localization.content.\(locale).\(key)")
  }
}
