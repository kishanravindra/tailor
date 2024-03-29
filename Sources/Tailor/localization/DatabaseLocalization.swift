/**
  This class localizes content using a table in the database.

  It requires a table called tailor_translations, with fields for
  translation_key, locale, and translated_text.
  */
public final class DatabaseLocalization: LocalizationSource {
  /** The locale that we are getting content in. */
  public let locale: String
  
  /**
    This method initializes a database localization.

    - parameter locale:   The locale that we are getting content in.
    */
  public init(locale: String) {
    self.locale = locale
  }
  
  /**
    This class models a translation from the database.
    */
  public struct Translation: Persistable, Equatable {
    /** The key that this is a translation for. */
    public var translationKey: String
    
    /** The locale this translation applies to. */
    public var locale: String
    
    /** The translated value. */
    public var translatedText: String
    
    /**
      This initializer creates a database localization.

      - parameter translationKey:    The key for the translation
      - parameter locale:            The locale for the translation.
      - parameter translatedText:    The text for the translation.
      */
    public init(translationKey: String, locale: String, translatedText: String) {
      self.translationKey = translationKey
      self.locale = locale
      self.translatedText = translatedText
      self.id = 0
    }


    //MARK: - Persistence

    /** The primary key of the record */
    public let id: UInt
    
    /** The name of the table in the database. */
    public static var tableName: String { return "tailor_translations" }
    
    /**
      This method gets the columns that we persist in the database from this 
      model.
      */
    public func valuesToPersist() -> [String : SerializationEncodable?] {
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

      - parameter values:     The fields from the database.
      */
    public init(deserialize values: SerializableValue) throws {
      self.translationKey = try values.read("translation_key")
      self.locale = try values.read("locale")
      self.translatedText = try values.read("translated_text")
      self.id = try values.read("id")
    }
    
    /** A query for fetching translations. */
    public static let query = Query<Translation>()
  }
  
  /**
    This method fetches localized text from the database.

    - parameter key:        The key for the localization
    - parameter locale:     The locale for the localization
    - returns:              The localized text, if we could find it.
    */
  public func fetch(key: String, inLocale locale: String) -> String? {
    let translation = Translation.query.filter(["locale": locale, "translation_key": key]).first()
    return translation?.translatedText
  }
  
  /**
    This method gets the locales that are available for translations.
    */
  public static var availableLocales: [String] {
    let sql = Translation.query.select("DISTINCT(locale) as locale").toSql()
    return Application.sharedDatabaseConnection().executeQuery(sql.query).flatMap {
      row in
      let value = row.data["locale"] ?? SerializableValue.Null
      return try? value.read() as String
    }.sort()
  }
}