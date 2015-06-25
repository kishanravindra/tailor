import Foundation

/**
  This class represents a source of localized content.

  This has been deprecated in favor of the LocalizationSource protocol.
  */
@available(*, deprecated, message="Use LocalizationSource instead") public class Localization: LocalizationSource {
  /** The locale for the content this source provides. */
  public let locale : String
  
  /**
    This method gets the locales that we should fall back to if we cannot find
    a translation for the locale we want.
  
    Locales will allow fallbacks from a country-specific locale to the global
    one for the same language (e.g. from es-mx to es), and from a language other
    than English to English (e.g. from es to en).

    - parameter locale:     The locale that we are supposed to be getting a
                            translation for.
    - returns:              The locales to try
    */
  public class func fallbackLocales(locale: String) -> [String] {
    return self.init(locale: locale).fallbackLocales()
  }
  
  /**
    This method creates a content source.

    - parameter locale:    The locale for the content.
    */
  public required init(locale: String) {
    self.locale = locale
  }
  
  /**
    This method gets the localized content for a key in the current locale.
  
    This implementation always returns nil, because this class provides no
    data source for the content. Subclasses must provide a real implementation.
  
    This will fall back to any other locales.

    - parameter key:    The key for the content
    - returns:          The content.
    */
  public func fetch(key: String, inLocale locale: String) -> String? {
    return nil
  }
}