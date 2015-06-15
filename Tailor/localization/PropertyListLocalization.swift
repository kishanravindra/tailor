

/**
  This class provides a source of localizations that are taken from a strings
  property list.
  */
public class PropertyListLocalization: Localization {
  /**
    This method gets the localized content for a key.
    
    - parameter key:   The key for the content
    - returns:     The content.
  */
  public override func fetch(key: String, inLocale locale: String) -> String? {
    return Application.sharedApplication().configuration.fetch("localization.content.\(locale).\(key)")
  }
}
