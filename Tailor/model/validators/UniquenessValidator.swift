import Tailor

/**
  This class provides a validator for a key being unique.

  If the value is nil, it will pass the validation.
  */
public class UniquenessValidator : Validator {
  public override func validate(model: Model) {
    if let record = model as? Record {
      let databaseKey : String! = record.dynamicType.persistedPropertyMapping()[self.key]
      let value : NSData? = record.valuesToPersist()[databaseKey]
      var stringValue : String? = nil
      if value != nil {
        stringValue = NSString(data: value!, encoding: NSUTF8StringEncoding)
      }
      if databaseKey == nil {
        return
      }
      
      if stringValue == nil {
        return
      }
      
      var duplicates : [Record] = []
      
      if record.id != nil {
        duplicates = record.dynamicType.query("SELECT * FROM \(record.dynamicType.tableName()) WHERE ? = ? AND id != ?", parameters: [databaseKey, stringValue!, String(record.id)])
      }
      else {
        duplicates = record.dynamicType.find(conditions: [databaseKey: stringValue!])
      }
      
      if !duplicates.isEmpty {
        model.errors.add(key, "is already taken")
      }
    }
  }
}