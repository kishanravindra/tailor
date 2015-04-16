import Foundation

/**
  This class provides a validator for a key being unique.

  If the value is nil, it will pass the validation.
  */
public class UniquenessValidator : Validator {
  public override func validate(model: Model) {
    if let record = model as? Record {
      let value = record.valuesToPersist()[self.key]
      var stringValue : String? = nil
      if value != nil && value! != nil {
        stringValue = NSString(data: value!!, encoding: NSUTF8StringEncoding) as? String
      }
      
      if stringValue == nil {
        return
      }
      
      let tableName = record.dynamicType.tableName()
      var query = "SELECT * FROM \(tableName) WHERE \(key) = ?"
      var parameters = [stringValue!]
      if record.id != nil {
        query += " AND id != ?"
        parameters.append(String(record.id!))
      }
      
      let duplicates = DatabaseConnection.sharedConnection().executeQuery(query, stringParameters: parameters)
      
      if !duplicates.isEmpty {
        model.errors.add(key, "taken")
      }
    }
  }
}