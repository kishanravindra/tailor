import Foundation

/**
  This protocol describes a source of localized content.
  */
public protocol LocalizationSource {
  /** The locale for the content this source provides. */
  var locale : String { get }
  
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
  func fallbackLocales() -> [String]
  
  /**
    This method creates a content source.
    
    - parameter locale:    The locale for the content.
    */
  init(locale: String)
  
  /**
    This method gets the localized content for a key in the current locale.
    
    This will fall back to any other locales.
    
    - parameter key:    The key for the content
    - returns:          The content.
    */
  func fetch(key: String, inLocale locale: String) -> String?
}

public extension LocalizationSource {
  public func fallbackLocales() -> [String] {
    var locales = [String]()
    if locale == "en" {
      return locales
    }
    var components = locale.componentsSeparatedByString("-")
    if components.count > 1 {
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
    
    - parameter key:              The key for the content.
    - parameter interpolations:   The values to interpolate into the content.
    - returns:                    The content.
    */
  public func fetch(key: String, interpolations: [String:String] = [:]) -> String? {
    var result = self.fetch(key, inLocale: self.locale)
    if result == nil {
      for fallbackLocale in self.fallbackLocales() {
        result = self.fetch(key, inLocale: fallbackLocale)
        if result != nil {
          break
        }
      }
    }
    for (key,value) in interpolations {
      result = result?.stringByReplacingOccurrencesOfString("\\(\(key))", withString: value, options: [], range: nil)
    }
    return result
  }
}