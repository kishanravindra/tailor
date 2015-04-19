/**
  This protocol describes methods that a model class must provide in order to
  be persisted to a database.
  */
public protocol Persistable: Equatable {
  /**
    This method initializes a record with a row from the database.
    
    If the row does not contain enough data to initialize the record, this must
    return nil.
    
    :param: databaseRow   The row from the database. The keys will be column
                          names, and the rows will be wrapped in the database
                          value wrapper.
    */
  init?(databaseRow: [String: DatabaseValue])
  
  /** The unique identifier for the record. */
  var id: Int? { get }
  
  /**
    This method provides name of the table that backs this class.
    :returns: The table name.
    */
  static func tableName() -> String
  
  /**
    This method gets the values to save to the database when this record is
    saved.
    
    The keys in the returned dictionary must be the names of the columns in the
    database.
    
    :returns:   The values to save.
    */
  func valuesToPersist() -> [String:DatabaseValueConvertible?]
}

//MARK: - Comparison

/**
  This method determines if two persistable records are equal.

  :param: lhs   The left-hand record
  :param: rhs   The right-hand record.
  :returns:     Whether they are equal.
*/
public func ==<T: Persistable>(lhs: T, rhs: T) -> Bool {
  return  lhs.id != nil &&
    rhs.id != nil &&
    lhs.id == rhs.id &&
    lhs.dynamicType.tableName() == rhs.dynamicType.tableName()
}

//MARK: - Associations

/**
  This method get the default name for a foreign key for a record class.

  It will be the underscored model name, followed by _id.
  :returns: The foreign key name.
  */
public func foreignKeyName(klass: Any.Type) -> String {
  return modelName(klass) + "_id"
}

/**
  This method fetches a relationship from one record to many related records.

  This will look for a field on the other record that contains the id of this
  record.

  :param: source      The record that is on the "one" side of the relationship.
  :param: foreignKey  The field on the other record type that contains the ids
                      of the source record. If this is omitted, we will use the
                      foreign key name specified by the `foriegnKeyName` method.
  :returns:           The records on the "many" side of the relationship.
*/
public func toManyRecords<RecordType: Persistable, OtherRecordType: Persistable>(source: RecordType, foreignKey inputForeignKey: String? = nil) -> Query<OtherRecordType> {
  let foreignKey = inputForeignKey ?? foreignKeyName(RecordType.self)
  return Query<OtherRecordType>().filter([foreignKey: source.id])
}

/**
  This method fetches a relationship from one record to many related records.

  This will use another relationship on the record as an intermediary, looking
  for a foreign key relationship between the intermediary and the final record
  type.

  :param: through           The query that contains the intermediary
                            relationship.
  :param: foreignKey        The attribute on the intermediary record that   
                            contains the id. If this is not provided, it will be 
                            the default foreign key name for the appropriate 
                            model.
  :param: joinToMany        Whether the join between the intermediary and the
                            final table should join from a foreign key on the
                            final to the id on the intermediate, rather than
                            from a foreign key on the intermediate to the id
                            on the final.
  :returns:                 The fetched records.
*/
public func toManyRecords<OtherRecordType : Persistable, IntermediaryRecordType: Persistable>(#through: Query<IntermediaryRecordType>, foreignKey inputForeignKey: String? = nil, joinToMany: Bool = false) -> Query<OtherRecordType> {
  var query = Query<OtherRecordType>()
  
  if joinToMany {
    let foreignKey = inputForeignKey ?? (foreignKeyName(IntermediaryRecordType.self))
    query = query.join(IntermediaryRecordType.self, fromColumn: "id", toColumn: foreignKey)
    
  }
  else {
    let foreignKey = inputForeignKey ?? (foreignKeyName(OtherRecordType.self))
    query = query.join(IntermediaryRecordType.self, fromColumn: foreignKey, toColumn: "id")
  }
  return query.filter(through.whereClause.query, through.whereClause.parameters.map { $0 as DatabaseValueConvertible })
}

/**
  This method saves a record to the database.

  It will also set values for the createdAt and updatedAt fields, if they
  are defined in the column mapping for the record type.

  :param: record    The record that we are saving.
  :returns:         On success, this returns a new record with the latest saved
                    information. On failure, this will return nil.
  */
public func saveRecord<RecordType: Persistable>(record: RecordType) -> RecordType? {
  
  var values = record.valuesToPersist()
  let properties = values.keys
  
  if contains(properties, "created_at") {
    if values["created_at"]! == nil {
      values["created_at"] = NSDate()
    }
  }
  if contains(properties, "updated_at") {
    values["updated_at"] = NSDate()
  }
  
  if record.id != nil {
    return updateRecord(record, values)
  }
  else {
    return insertRecord(record, values)
  }
}



/**
This method saves the record to the database by inserting it.

:returns:   Whether we were able to save the record.
*/
private func insertRecord<RecordType: Persistable>(record: RecordType, values: [String:DatabaseValueConvertible?]) -> RecordType? {
  var query = "INSERT INTO \(RecordType.tableName()) ("
  var parameters = [DatabaseValue]()
  
  var firstParameter = true
  var parameterString = ""
  var mappedValues = [String:DatabaseValue]()
  
  for key in sorted(values.keys) {
    let value = values[key]!
    
    let databaseValue = value?.databaseValue ?? DatabaseValue.Null
    mappedValues[key] = databaseValue
    
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
    parameters.append(databaseValue)
  }
  query += ") VALUES (\(parameterString))"
  
  let results = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
  
  let result : DatabaseConnection.Row? = results.isEmpty ? nil : results[0]
  
  if result == nil {
    return nil
  }
  else if let error = result?.error {
    return nil
  }
  else {
    mappedValues["id"] = result?.data["id"]
    return RecordType.init(databaseRow: mappedValues)
  }
}

private func updateRecord<RecordType: Persistable>(record: RecordType, values: [String:DatabaseValueConvertible?]) -> RecordType? {
  
  var query = "UPDATE \(RecordType.tableName())"
  var parameters = [DatabaseValue]()
  var mappedValues = [String:DatabaseValue]()
  
  var firstParameter = true
  for key in sorted(values.keys) {
    let value = values[key]!
    let databaseValue = value?.databaseValue ?? DatabaseValue.Null
    mappedValues[key] = databaseValue
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
      parameters.append(databaseValue)
    }
  }
  query += " WHERE id = ?"
  parameters.append(record.id!.databaseValue)
  mappedValues["id"] = record.id!.databaseValue
  let result = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
  
  if result.count > 0 {
    if let error = result[0].error {
      NSLog("Error in query: %@", error)
      return nil
    }
  }
  NSLog("Mapped values are %@", mappedValues.description)
  return RecordType.init(databaseRow: mappedValues)
}

/**
  This method deletes the record from the database.

  :param: record    The record to delete.
  */
public func destroyRecord<RecordType: Persistable>(record: RecordType) {
  if record.id != nil {
    let query = "DELETE FROM \(RecordType.tableName()) WHERE id = ?"
    DatabaseConnection.sharedConnection().executeQuery(query, parameters: [record.id!.databaseValue])
  }
}

