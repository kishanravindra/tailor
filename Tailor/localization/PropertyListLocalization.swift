

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
    return Application.configuration.staticContent["\(locale).\(key)"]
  }
  
  /**
    This method gets the locales from the keys in the application's static
    configuration.
  
    You can assign this to availableLocales if you need to reload the locales
    after a change to the static content.
    */
  public static func localesFromConfiguration() -> [String] {
    var locales = Set<String>()
    for key in Application.configuration.staticContent.keys {
      locales.insert(String(key.characters.split(".").first ?? key.characters))
    }
    return Array(locales).sort()
  }
  
  /**
    This method gets the available locales in the application's static
    configuration.
    */
  public static var availableLocales = PropertyListLocalization.localesFromConfiguration()
}
