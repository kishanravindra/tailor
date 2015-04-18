import Foundation

/**
  This class provides a base class for models backed by the database.
  */
public class Record : Model, Equatable {
  /** The unique identifier for the record. */
  public private(set) var id : Int?
  
  public init(id: Int? = nil) {
    self.id = id
  }
  
  //MARK: - Structure
  
  /**
    This method provides name of the table that backs this class.

    This implementation returns the pluralized version of the model name, but
    subclasses can override that if they have a different table naming
    convention.

    :returns: The table name.
    */
  public class func tableName() -> String {
    return self.modelName().pluralized
  }
  
  /**
    This method get the default name of an attribute holding a foreign key for
    this model.
  
    It will be in lowercase camel case. The default version is the camel cased
    model name, followed by Id.
  
    :returns: The foreign key name.
  */
  public class func foreignKeyName() -> String {
    return self.modelName() + "_id"
  }
  
  /**
    This method fetches a relationship from this record to one other record.

    This will look for a field on this record that contains the id of the other
    record.

    :param: foreignKey    The attribute on this record that contains the id. If
                          this is not provided, it will be the default foreign
                          key name for the other model.
    :returns:             The fetched record.
    */
  public func toOne<OtherRecordType : Record>(foreignKey inputForeignKey: String? = nil) -> OtherRecordType? {
    let foreignKey = inputForeignKey ?? (OtherRecordType.foreignKeyName())
    return Query<OtherRecordType>().filter(["id": self.valueForKey(foreignKey)]).first()
  }
  
  /**
    This method fetches a relationship from this record to many related records.
  
    This will look for a field on the other record that contains the id of this
    record.
  
    :param: foreignKey    The attribute on the other record that contains the
                          id. If this is not provided, it will be the default
                          foreign key name for this model.
    :returns:             The fetched records.
  */
  public func toMany<OtherRecordType : Record>(foreignKey inputForeignKey: String? = nil) -> Query<OtherRecordType> {
    let foreignKey = inputForeignKey ?? (self.dynamicType.foreignKeyName())
    return Query<OtherRecordType>().filter([foreignKey: self.id])
  }
  
  /**
    This method fetches a relationship from this record to many related records.
  
    This will use another relationship on the record as an intermediary, looking
    for a foreign key relationship between the intermediary and the final record
    type.
  
    :param: through           The relation
    :param: foreignKey        The attribute on the intermediary record that contains the
                              id. If this is not provided, it will be the default
                              foreign key name for the appropriate model.
    :param: joinToMany        Whether the join between the intermediary and the
                              final table should join from a foreign key on the
                              final to the id on the intermediate, rather than
                              from a foreign key on the intermediate to the id
                              on the final.
    :returns:                 The fetched records.
  */
  public func toMany<OtherRecordType : Record, IntermediaryRecordType: Record>(#through: Query<IntermediaryRecordType>, foreignKey inputForeignKey: String? = nil, joinToMany: Bool = false) -> Query<OtherRecordType> {
    var query = Query<OtherRecordType>()
    
    if joinToMany {
      let foreignKey = inputForeignKey ?? (IntermediaryRecordType.foreignKeyName())
      query = query.join(IntermediaryRecordType.self, fromColumn: "id", toColumn: foreignKey)
      
    }
    else {
      let foreignKey = inputForeignKey ?? (OtherRecordType.foreignKeyName())
      query = query.join(IntermediaryRecordType.self, fromColumn: foreignKey, toColumn: "id")
    }
    return query.filter(through.whereClause.query, through.whereClause.parameters)
  }
  
  //MARK: - Creating
  
  /**
    This method takes a value of an arbitrary type and serializes it so it can
    be put into a query.

    :param: value     The value to serialize.
    :param: key       The key that the value is for. This implementation does
                      nothing with it, but subclasses can use this to provide
                      custom serialization for vertain keys.
    :returns:         The value serialized as both a string and an NSData
                      object, so it can be used in either type of query.
    */
  public class func serializeValueForQuery(value: AnyObject?, key: String) -> (String?, NSData?) {
    var stringValue: String? = nil
    var dataValue: NSData? = nil
    switch value {
    case let string as String:
      stringValue = string
    case let date as NSDate:
      let timeZone = DatabaseConnection.sharedConnection().timeZone
      stringValue = date.format("db", timeZone: timeZone)
    case let number as NSNumber:
      stringValue = number.stringValue
    case let data as NSData:
      dataValue = data
    default:
      break
    }
    
    if dataValue == nil && stringValue != nil {
      dataValue = stringValue!.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    return (stringValue, dataValue)
  }
  
  //MARK: - Persisting
  
  public class func decode(databaseRow: [String:DatabaseValue]) -> Self? {
    return nil
  }
  
  /**
    This method gets the values to save to the database when this record is
    saved.
  
    This is one of the two key methods that subclasses should override to
    provide their data mapping. The keys in the returned dictionary should be
    the names of the columns in the database. The values should be an encoded
    string or raw data blob that will go in that column.
  
    :returns:   The values to save.
    */
  public func valuesToPersist() -> [String:DatabaseValueConvertible?] {
    return [:]
  }
  
  /**
    This method saves the record to the database.
  
    It will also set values for the createdAt and updatedAt fields, if they
    are defined.
  
    :returns: Whether we were able to save the record.
    */
  public func save() -> Bool {
    if !self.validate() {
      return false
    }
    
    var values = self.valuesToPersist()
    let properties = values.keys
    
    if contains(properties, "created_at") {
      if values["created_at"]! == nil {
        values["created_at"] = NSDate()
      }
    }
    if contains(properties, "updated_at") {
      values["updated_at"] = NSDate()
    }
    
    if self.id != nil {
      return self.saveUpdate(values)
    }
    else {
      return self.saveInsert(values)
    }
  }
  
  /**
    This method saves the record to the database by inserting it.
  
    :returns:   Whether we were able to save the record.
    */
  private func saveInsert(values: [String:DatabaseValueConvertible?]) -> Bool {
    var query = "INSERT INTO \(self.dynamicType.tableName()) ("
    var parameters = [DatabaseValue]()
    
    var firstParameter = true
    var parameterString = ""
    for key in sorted(values.keys) {
      let value = values[key]!
      if value == nil {
        continue
      }
      if firstParameter {
        firstParameter = false
      }
      else {
        query += ", "
        parameterString += ", "
      }
      query += "\(DatabaseConnection.sanitizeColumnName(key))"
      parameterString += "?"
      
      let databaseValue = value?.databaseValue ?? DatabaseValue.Null
      parameters.append(databaseValue)
    }
    query += ") VALUES (\(parameterString))"
    
    let results = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
    
    let result : DatabaseConnection.Row? = results.isEmpty ? nil : results[0]
    
    if result == nil {
      self.id = 0
      return false
    }
    else if let error = result?.error {
      self.errors.add("_database", error)
      return false
    }
    else {
      self.id = result?.data["id"]?.intValue
      return true
    }
  }
  
  /**
    This method saves the record to the database by updating it.
  
    :returns:   Whether we were able to save the record.
    */
  private func saveUpdate(values: [String:DatabaseValueConvertible?]) -> Bool {
    var query = "UPDATE \(self.dynamicType.tableName())"
    var parameters = [DatabaseValue]()
    
    if self.id == nil {
      self.errors.add("_database", "cannot update record without id")
      return false
    }
    var firstParameter = true
    for key in sorted(values.keys) {
      let value = values[key]!
      if firstParameter {
        query += " SET "
        firstParameter = false
      }
      else {
        query += ", "
      }
      query += "\(DatabaseConnection.sanitizeColumnName(key)) = "
      if value == nil {
        query += "NULL"
      }
      else {
        query += "?"
        parameters.append(value!.databaseValue)
      }
    }
    query += " WHERE id = ?"
    parameters.append(self.id!.databaseValue)
    let result = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
    
    if result.count > 0 {
      if let error = result[0].error {
        self.errors.add("_database", error)
        return false
      }
    }
    return true
  }
  
  /**
    This method deletes the record from the database.
    */
  public func destroy() {
    if self.id != nil {
      let query = "DELETE FROM \(self.dynamicType.tableName()) WHERE id = ?"
      DatabaseConnection.sharedConnection().executeQuery(query, parameters: [self.id!.databaseValue])
    }
  }
  
  //MARK: - Serialization
  
  /**
    This method converts a record into a simple property list.

    The property list will contain all of the persisted properties.
  
    :returns:   The property list.
    */
  public func toPropertyList() -> [String:AnyObject] {
    var propertyList = [String:AnyObject]()
    propertyList["id"] = self.id
    let values = self.valuesToPersist()
    for key in sorted(values.keys) {
      let value = values[key]!
      let databaseValue = value?.databaseValue ?? DatabaseValue.Null
      propertyList[key] = databaseValue.description
    }
    return propertyList
  }
}

//MARK: - Comparison

/**
  This method determines if two records are equal.

  Records will be equal whenever they are from the same table and have the same
  id.
  
  :param: lhs   The left-hand record
  :param: rhs   The right-hand record.
  :returns:     Whether they are equal.
  */
public func ==(lhs: Record, rhs: Record) -> Bool {
  return  lhs.id != nil &&
          rhs.id != nil &&
          lhs.id == rhs.id &&
          lhs.dynamicType.tableName() == rhs.dynamicType.tableName()
}