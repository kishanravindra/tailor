import Foundation

/**
  This class represents a source of localized content.
  */
public class Localization {
  /** The locale for the content this source provides. */
  public let locale : String
  
  /**
    This method gets the locales that we should fall back to if we cannot find
    a translation for the locale we want.
  
    Locales will allow fallbacks from a country-specific locale to the global
    one for the same language (e.g. from es-mx to es), and from a language other
    than English to English (e.g. from es to en).

    :param: locale    The locale that we are supposed to be getting a
                      translation for.
    :returns:         The locales to try
    */
  public class func fallbackLocales(locale: String) -> [String] {
    var locales = [String]()
    if locale == "en" {
      return locales
    }
    var components = split(locale) { $0 == "-" }
    if countElements(components) > 1 {
      var fallback = ""
      for component in components {
        if !fallback.isEmpty {
          fallback += "-"
        }
        fallback += component
        if fallback == locale {
          break
        }
        locales.insert(fallback, atIndex: 0)
      }
      if components[0] != "en" {
        locales.append("en")
      }
    }
    else {
      locales.append("en")
    }
    return locales
  }
  
  /**
    This method creates a content source.

    :param: locale    The locale for the content.
    */
  public required init(locale: String) {
    self.locale = locale
  }
  
  /**
    This method gets the localized content for a key, falling back to other
    locales.

    The other locales are defined in the fallbackLocales class method.
  
    Subclasses should not override this method. If they need to define a
    different behavior for fetching the content in a given locale, they should
    override fetchInLocale. If they need to change the way the fallbacks work,
    they should override fallbackLocales.
  
    This can also interpolate dynamic values into the content, as provided in
    the interpolations parameter. If there is a key "name" in that dictionary
    mapped to the value "John", then all occurrences of "\(name)" in the content
    will be replaced with "John".
    
    :param: key             The key for the content.
    :param: interpolations  The values to interpolate into the content.
    :returns:               The content.
    */
  public func fetch(key: String, interpolations: [String:String] = [:]) -> String? {
    var result = self.fetch(key, inLocale: self.locale)
    if result == nil {
      for fallbackLocale in self.dynamicType.fallbackLocales(self.locale) {
        result = self.fetch(key, inLocale: fallbackLocale)
        if result != nil {
          break
        }
      }
    }
    for (key,value) in interpolations {
      result = result?.stringByReplacingOccurrencesOfString("\\(\(key))", withString: value, options: nil, range: nil)
    }
    return result
  }
  
  /**
    This method gets the localized content for a key in the current locale.
  
    This implementation always returns nil, because this class provides no
    data source for the content. Subclasses must provide a real implementation.
  
    This will fall back to any other locales.

    :param: key   The key for the content
    :returns:     The content.
    */
  public func fetch(key: String, inLocale locale: String) -> String? {
    return nil
  }
}