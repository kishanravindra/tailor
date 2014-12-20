import Foundation

/**
  This class provides a validator for a key being unique.

  If the value is nil, it will pass the validation.
  */
public class UniquenessValidator : Validator {
  public override func validate(model: Model) {
    if let record = model as? Record {
      let databaseKey : String! = record.dynamicType.columnNameForField(self.key)
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
      
      let tableName = record.dynamicType.tableName()
      var query = "SELECT * FROM \(tableName) WHERE ? = ?"
      var parameters = [databaseKey!, stringValue!]
      if record.id != nil {
        query += " AND id != ?"
        parameters.append(record.id.stringValue)
      }
      
      let duplicates = DatabaseConnection.sharedConnection().executeQuery(query, stringParameters: parameters)
      
      if !duplicates.isEmpty {
        model.errors.add(key, "is already taken")
      }
    }
  }
}