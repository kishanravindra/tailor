/**
  This protocol describes methods that a model class must provide in order to
  be persisted to a database.
  */
public protocol Persistable: ModelType, SerializationEncodable {
  /**
    This method initializes a record with a row from the database.
    
    If the row does not contain enough data to initialize the record, this must
    throw an exception.
    
    - parameter values:     A serialized dictionary containing the values from
                            the database.
    */
  init(values: SerializableValue) throws
  
  /** The unique identifier for the record. */
  var id: UInt { get }
  
  /**
    This method provides name of the table that backs this class.
  
    The default implementation uses the name of the type, in snake case, and
    pluralized.
    
    - returns: The table name.
    */
  static var tableName: String { get }
  
  /**
    This method gets the values to save to the database when this record is
    saved.
    
    The keys in the returned dictionary must be the names of the columns in the
    database.
    
    - returns:   The values to save.
    */
  func valuesToPersist() -> [String:SerializationEncodable?]
  
  /**
    This method provides an empty query for fetching records for this record
    type.

    There is a default implementation that returns a `GenericQuery`, but because
    of a compiler bug you *must* provide an implementation for any structs that
    conform to the protocol. Additionally, it is recommended that you provide an
    implementation of all types that returns a parameterized `Query` rather than
    a `GenericQuery`, so that you can use it to fetch results that are properly
    cast to the record type.
    */
  static var query: QueryType { get }
}

//MARK: - Comparison

public func ==<T: Persistable>(lhs: T, rhs: T) -> Bool {
  return lhs.id == rhs.id &&
    lhs.dynamicType.tableName == rhs.dynamicType.tableName
}
extension Persistable {
  
  /**
    This method builds a record from a row in the database.
    
    It wraps around the initializer to catch exceptions and log them, returning
    nil in the case of failure.
    
    - parameter values:   The row to use to build the object.
    - returns:            The new record.
    */
  internal static func build(values: SerializableValue) -> Self? {
    do {
      return try self.init(values: values)
    }
    catch let DatabaseError.GeneralError(message) {
      NSLog("Error building record in %@: %@", self.tableName, message)
    }
    catch let DatabaseError.MissingField(name) {
      NSLog("Error building record in %@: %@ was missing", self.tableName, name)
    }
    catch let DatabaseError.FieldType(name, actualType, desiredType) {
      NSLog("Error building record in %@: %@ should be %@, but was %@", self.tableName, name, desiredType, actualType)
    }
    catch {
      NSLog("Unknown error building record")
    }
    return nil
  }
  
  /** Whether the record has been saved to the database. */
  public var persisted: Bool { return self.id > 0 }

  /**
    This method saves a record to the database.
    
    It will also set values for the createdAt and updatedAt fields, if they
    are defined in the column mapping for the record type.
  
    - returns:              On success, this returns a new record with the
                            latest saved information. On failure, this will
                            return nil.
  */
  public func save() -> Self? {
    var values = self.valuesToPersist()
    let properties = values.keys
    
    if properties.contains("created_at") {
      if (values["created_at"] ?? nil) == nil {
        values["created_at"] = Timestamp.now()
      }
    }
    if properties.contains("updated_at") {
      values["updated_at"] = Timestamp.now()
    }
    
    if self.persisted {
      return updateRecord(values)
    }
    else {
      return insertRecord(values)
    }
  }
  
  /**
    This method deletes the record from the database.
    */
  public func destroy() {
    let query = "DELETE FROM \(self.dynamicType.tableName) WHERE id = ?"
    Application.sharedDatabaseConnection().executeQuery(query, parameters: [id.serialize()])
  }

  /**
    This method fetches a relationship from this record to many related records.

    This will look for a field on the other record that contains the id of this
    record.
  
    - parameter foreignKey:   The field on the other record type that contains
                              the ids of the source record. If this is omitted,
                              we will use the foreign key name specified by the
                              `foriegnKeyName` method.
    - returns:                The records on the "many" side of the relationship.
  */
  public func toMany<OtherRecordType: Persistable>(foreignKey inputForeignKey: String? = nil) -> Query<OtherRecordType> {
    let foreignKey = inputForeignKey ?? self.dynamicType.foreignKeyName()
    return Query<OtherRecordType>().filter([foreignKey: self.id])
  }

  /**
    This method fetches a relationship from this record to many related records.

    This will use another relationship on the record as an intermediary, looking
    for a foreign key relationship between the intermediary and the final record
    type.

    - parameter through:      The query that contains the intermediary
                              relationship.
    - parameter foreignKey:   The attribute on the intermediary record that
                              contains the id. If this is not provided, it will be
                              the default foreign key name for the appropriate
                              model.
    - parameter joinToMany:   Whether the join between the intermediary and the
                              final table should join from a foreign key on the
                              final to the id on the intermediate, rather than
                              from a foreign key on the intermediate to the id
                              on the final.
    - returns:                The fetched records.
  */
  public func toMany<OtherRecordType : Persistable, IntermediaryRecordType: Persistable>(through through: Query<IntermediaryRecordType>, foreignKey inputForeignKey: String? = nil, joinToMany: Bool = false) -> Query<OtherRecordType> {
    var query = Query<OtherRecordType>()
    
    if joinToMany {
      let foreignKey = inputForeignKey ?? IntermediaryRecordType.foreignKeyName()
      query = query.join(IntermediaryRecordType.self, fromColumn: "id", toColumn: foreignKey)
      
    }
    else {
      let foreignKey = inputForeignKey ?? OtherRecordType.foreignKeyName()
      query = query.join(IntermediaryRecordType.self, fromColumn: foreignKey, toColumn: "id")
    }
    let existingJoinClause = through.joinClause
    if !existingJoinClause.query.isEmpty {
      query = query.join(existingJoinClause.query, existingJoinClause.parameters.map { $0 as SerializationConvertible })
    }
    return query.filter(through.whereClause.query, through.whereClause.parameters.map { $0 as SerializationConvertible })
  }
  
  /**
    This method saves the record to the database by inserting it.
    
    - returns:   A new record with the new fields.
    */
  private func insertRecord(values: [String:SerializationEncodable?]) -> Self? {
    var query = "INSERT INTO \(self.dynamicType.tableName) ("
    var parameters = [SerializableValue]()
    
    var firstParameter = true
    var parameterString = ""
    var mappedValues = [String:SerializableValue]()
    
    for key in values.keys.sort() {
      guard let value = values[key] else { continue }
      
      let databaseValue = value?.serialize() ?? SerializableValue.Null
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
      query += "\(Application.sharedDatabaseConnection().sanitizeColumnName(key))"
      parameterString += "?"
      parameters.append(databaseValue)
    }
    
    if values.isEmpty {
      query += "id"
      parameterString = "NULL"
    }
    query += ") VALUES (\(parameterString))"
    
    let results = Application.sharedDatabaseConnection().executeQuery(query, parameters: parameters)
    
    let result : DatabaseRow? = results.isEmpty ? nil : results[0]
    
    if result == nil {
      return nil
    }
    else if result?.error != nil {
      return nil
    }
    else {
      mappedValues["id"] = result?.data["id"]
      return self.dynamicType.build(.Dictionary(mappedValues))
    }
  }
  
  private func updateRecord(values: [String:SerializationEncodable?]) -> Self? {
    var query = "UPDATE \(self.dynamicType.tableName)"
    var parameters = [SerializableValue]()
    var mappedValues = [String:SerializableValue]()
    
    var firstParameter = true
    for key in values.keys.sort() {
      guard let value = values[key] else { continue }
      let databaseValue = value?.serialize() ?? SerializableValue.Null
      mappedValues[key] = databaseValue
      if firstParameter {
        query += " SET "
        firstParameter = false
      }
      else {
        query += ", "
      }
      query += "\(Application.sharedDatabaseConnection().sanitizeColumnName(key)) = "
      if value == nil {
        query += "NULL"
      }
      else {
        query += "?"
        parameters.append(databaseValue)
      }
    }
    query += " WHERE id = ?"
    parameters.append(id.serialize())
    mappedValues["id"] = id.serialize()
    let result = Application.sharedDatabaseConnection().executeQuery(query, parameters: parameters)
    
    if result.count > 0 {
      if let error = result[0].error {
        NSLog("Error in query: %@", error)
        return nil
      }
    }
    return self.dynamicType.build(.Dictionary(mappedValues))
  }
  
  /**
    This method gets the name of foreign keys pointing to this record type.

    This will be the model name followed by `_id`.
    */
  public static func foreignKeyName() -> String {
    return self.modelName() + "_id"
  }
  
  /**
    This method gets a query for fetching records of this record type.

    The default implementation uses a generic query with this record type and
    table name.
    */
  public static var query: QueryType { return GenericQuery(recordType: self, tableName: self.tableName) }
  
  /**
    This method gets the name of the table where we store records for this
    record type.

    The default implementation uses the plural of the model name, in snake case.
    */
  public static var tableName: String { return self.modelName().pluralized }
}

extension Persistable {
  /**
   This method converts the record to a serializable representation.
   
   The default implementation takes the database mapping from `valuesToPersist`
   to a serializable dictionary.
   
   - returns:    The JSON value.
   */
  public func serialize() -> SerializableValue {
    let values = self.valuesToPersist().map { $0?.serialize() ?? .Null }
    return .Dictionary(merge(values, ["id": self.id.serialize() ?? .Null]))
  }
}

@available(*, deprecated)
extension Persistable {
  /**
    This method converts the record to a JSON representation.

    The default implementation takes the database mapping from `valuesToPersist`
    to a JSON dictionary.

    - returns:    The JSON value.
    */
  public func toJson() -> JsonPrimitive {
    let values = self.valuesToPersist().map { $0?.serialize() ?? .Null }
    return .Dictionary(merge(values, ["id": self.id.serialize() ?? .Null]))
  }
}