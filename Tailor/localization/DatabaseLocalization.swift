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
    public dynamic var translationKey: String
    
    /** The locale this translation applies to. */
    public dynamic var locale: String
    
    /** The translated value. */
    public dynamic var translatedText: String
    
    public override class func tableName() -> String {
      return "tailor_translations"
    }
    
    public override class func modelName() -> String {
      return "translation"
    }
    
    public override func valuesToPersist() -> [String : NSData?] {
      return [
        "translation_key": self.translationKey.dataUsingEncoding(NSUTF8StringEncoding),
        "locale": self.locale.dataUsingEncoding(NSUTF8StringEncoding),
        "translated_text": self.translatedText.dataUsingEncoding(NSUTF8StringEncoding)
        ]
    }
    
    public init(translationKey: String, locale: String, translatedText: String, id: Int? = nil) {
      self.translationKey = translationKey
      self.locale = locale
      self.translatedText = translatedText
      super.init(id: id)
    }
    
    public override class func decode(databaseRow: [String:Any]) -> Self? {
      if let translationKey = databaseRow["translation_key"] as? String,
        locale = databaseRow["locale"] as? String,
        translatedText = databaseRow["translated_text"] as? String,
        id = databaseRow["id"] as? Int {
          return self.init(translationKey: translationKey, locale: locale, translatedText: translatedText, id: id)
      }
      else {
        return nil
      }
    }
    
    public override class func validators() -> [Validator] {
      return [
        PresenceValidator(key: "translationKey"),
        PresenceValidator(key: "locale")
      ]
    }
  }
  
  public override func fetch(key: String, inLocale locale: String) -> String? {
    let translation = Query<Translation>().filter(["locale": locale, "translation_key": key]).first()
    return translation?.translatedText
  }
}