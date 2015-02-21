import Foundation

/**
  This class represents a source of localized content.
  */
public class Localization {
  /** The locale for the content this source provides. */
  public let locale : String
  
  /**
    This method creates a content source.

    :param: locale    The locale for the content.
    */
  public required init(locale: String) {
    self.locale = locale
  }
  
  /**
    This method gets the localized content for a key.
  
    This implementation always returns nil, because this class provides no
    data source for the content. Subclasses must provide a real implementation.

    :param: key   The key for the content
    :returns:     The content.
    */
  public func fetch(key: String) -> String? {
    return nil
  }
}