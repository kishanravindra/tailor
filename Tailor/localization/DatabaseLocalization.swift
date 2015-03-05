/**
  This class localizes content using a table in the database.

  It requires a table called tailor_translations, with fields for
  translation_key, locale, and translated_text.
  */
public class DatabaseLocalization: Localization {
  /**
    This class models a translation from the database.
    */
  public class Translation: Record {
    /** The key that this is a translation for. */
    public dynamic var translationKey: String!
    
    /** The locale this translation applies to. */
    public dynamic var locale: String!
    
    /** The translated value. */
    public dynamic var translatedText: String?
    
    public override class func tableName() -> String {
      return "tailor_translations"
    }
    
    public override class func modelName() -> String {
      return "translation"
    }
    
    public override class func persistedProperties() -> [String] {
      return ["translationKey", "locale", "translatedText"]
    }
    
    public override class func validators() -> [Validator] {
      return [
        PresenceValidator(key: "translationKey"),
        PresenceValidator(key: "locale")
      ]
    }
  }
  
  public override func fetch(key: String, inLocale locale: String) -> String? {
    let translation = Query<Translation>().filter(["locale": locale, "translationKey": key]).first()
    return translation?.translatedText
  }
}