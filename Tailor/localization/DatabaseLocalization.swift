/**
  This class localizes content using a table in the database.

  It requires a table called tailor_translations, with fields for
  translation_key, locale, and translated_text.
  */
public class DatabaseLocalization: Localization {
  /**
    This class models a translation from the database.
    */
  public struct Translation: Persistable {
    /** The key that this is a translation for. */
    public var translationKey: String
    
    /** The locale this translation applies to. */
    public var locale: String
    
    /** The translated value. */
    public var translatedText: String
    
    public init(translationKey: String, locale: String, translatedText: String) {
      self.translationKey = translationKey
      self.locale = locale
      self.translatedText = translatedText
      self.id = nil
    }


    //MARK: - Persistence

    /** The primary key of the record */
    public let id: Int?
    
    /** The name of the table in the database. */
    public static func tableName() -> String { return "tailor_translations" }
    
    /**
      This method gets the columns that we persist in the database from this 
      model.
      */
    public func valuesToPersist() -> [String : DatabaseValueConvertible?] {
      return [
        "translation_key": self.translationKey,
        "locale": self.locale,
        "translated_text": self.translatedText
        ]
    }
    
    /**
      This method initializes a translation from a row in the database.

      The row must have fields for translation_key, locale, translated_text, and
      id. If these fields are not present, this initializer will return nil.

      :param: databaseRow     The fields from the database.
      */
    public init?(databaseRow: [String:DatabaseValue]) {
      if let translationKey = databaseRow["translation_key"]?.stringValue,
        locale = databaseRow["locale"]?.stringValue,
        translatedText = databaseRow["translated_text"]?.stringValue,
        id = databaseRow["id"]?.intValue {
          self.id = id
          self.translationKey = translationKey
          self.locale = locale
          self.translatedText = translatedText
      }
      else {
        self.translationKey = ""
        self.locale = ""
        self.translatedText = ""
        self.id = nil
        return nil
      }
    }
  }
  
  public override func fetch(key: String, inLocale locale: String) -> String? {
    let translation = Query<Translation>().filter(["locale": locale, "translation_key": key]).first()
    return translation?.translatedText
  }
}