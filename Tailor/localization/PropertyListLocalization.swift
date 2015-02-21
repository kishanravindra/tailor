

/**
  This class provides a source of localizations that are taken from a strings
  property list.
  */
public class PropertyListLocalization: Localization {
  /**
    This method gets the localized content for a key.
    
    :param: key   The key for the content
    :returns:     The content.
  */
  public override func fetch(key: String) -> String? {
    return Application.sharedApplication().configuration.fetch("localization.content.\(self.locale).\(key)")
  }
}
