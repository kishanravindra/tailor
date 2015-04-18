import Foundation

/**
  This class provides a validator for a key being unique.

  If the value is nil, it will pass the validation.
  */
public class UniquenessValidator : Validator {
  public override func validate(model: Model) {
    if let record = model as? Record {
      let value = record.valuesToPersist()[self.key]
      
      if value == nil {
        return
      }
      
      let databaseValue = value!?.databaseValue ?? DatabaseValue.Null
      let tableName = record.dynamicType.tableName()
      var query = "SELECT * FROM \(tableName) WHERE \(key) = ?"
      var parameters = [databaseValue]
      if record.id != nil {
        query += " AND id != ?"
        parameters.append(record.id!.databaseValue)
      }
      
      let duplicates = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
      
      if !duplicates.isEmpty {
        model.errors.add(key, "taken")
      }
    }
  }
}