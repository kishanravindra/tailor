import Foundation

/**
  This structure represents a row of data returned from the database.
  */
public struct DatabaseRow {
  /** The data returned for the row. */
  public let data: [String:SerializableValue]
  
  /** The error message that the database gave for this query. */
  public private(set) var error: String?
  
  /**
  This method initializes a row with a hash of data.
  
  - parameter data:   The data for the row.
  */
  public init(data: [String:SerializableValue]) {
    self.data = data
  }
  
  /**
  This method initializes a row with a hash of values that can be mapped
  to database values.
  
  - parameter rawData:   The unwrapped data.
  */
  public init(rawData: [String:SerializationConvertible]) {
    var wrappedData = [String:SerializableValue]()
    for (key,value) in rawData {
      wrappedData[key] = value.serialize
    }
    self.init(data: wrappedData)
  }
  
  /**
  This method initializees a row for an error message.
  */
  public init(error: String) {
    self.init(data: [:])
    self.error = error
  }
  
  /**
    This method reads a value from our data dictionary and attempts to cast it
    to another type.
    
    This will infer the desired return type from the calling context.
    
    If there is no value for that key, or if the value cannot be cast to a
    compatible type, this will throw an exception.
    
    This will use the `stringValue`, `intValue`, etc. family of methods on
    `DatabaseValue` to do the casting, so whereever those methods support
    automatic conversion, so will this method.
   
    This has been deprecated in favor of converting the row to a serializable
    value using `serialize`, and then calling `read` on that value.
    
    - parameter key:    The key to read.
    - returns:          The cast value.
    - throws:           An exception from `DatabaseError`.
    */
  @available(*, deprecated, message="Use the `serialize` method and call `read` on the result")
  public func read<OutputType: DatabaseValueConvertible>(key: String) throws -> OutputType {
    guard let value = self.data[key] else {
      throw DatabaseError.MissingField(name: key)
    }
    
    switch(OutputType.self) {
    case is String.Type:
      if let cast = value.stringValue as? OutputType {
        return cast
      }
    case is Int.Type:
      if let cast = value.intValue as? OutputType { return cast }
    case is UInt.Type:
      if let int = value.intValue, let cast = UInt(int) as? OutputType { return cast }
    case is Timestamp.Type:
      if let cast = value.timestampValue as? OutputType { return cast }
    case is Date.Type:
      if let cast = value.dateValue as? OutputType { return cast }
    case is Time.Type:
      if let cast = value.timeValue as? OutputType { return cast }
    case is NSData.Type:
      if let cast = value.dataValue as? OutputType { return cast }
    case is Double.Type:
      if let cast = value.doubleValue as? OutputType { return cast }
    case is Bool.Type:
      if let cast = value.boolValue as? OutputType { return cast }
    default:
      break
    }
    let typeName = String(OutputType.self)
    var actualTypeName = String(value)
    if let index = actualTypeName.characters.indexOf("(") {
      actualTypeName = actualTypeName.substringToIndex(index)
    }
    throw DatabaseError.FieldType(name: key, actualType: actualTypeName, desiredType: typeName)
  }
  
  /**
    This method reads a value from our data dictionary and attempts to cast it
    to another type.
    
    This will infer the desired return type from the calling context.
    
    This method wraps around the other version of `read` which returns a
    non-optional type. If the value is missing, or is a null database value,
    this will return nil.
   
    This has been deprecated in favor of converting the row to a serializable
    value using `serialize`, and then calling `read` on that value.
   
    - parameter key:    The key to read.
    - returns:          The cast value.
    - throws:           An exception from `DatabaseError`.
    */
  @available(*, deprecated, message="Use the `serialize` method and call `read` on the result")
  public func read<OutputType: DatabaseValueConvertible>(key: String) throws -> OutputType? {
    guard let value = self.data[key] else { return nil }
    if value == .Null { return nil }
    if value == .String("") { return nil }
    let result: OutputType = try self.read(key)
    return result
  }
  
  
  /**
    This method reads a row from the database from an id fetched from another
    table.
   
    This has been deprecated in favor of converting the row to a serializable
    value using `serialize`, and then calling `read` on that value.
   
    - parameter fieldName:    The name of the field that contains the id.
    - returns:                The fetched record.
    - throws:                 A DatabaseError explaining why we couldn't fetch
    the record.
   */
  @available(*, deprecated, message="Use the `serialize` method and call `read` on the result")
  public func read<RecordType: Persistable>(fieldName: String) throws -> RecordType? {
    guard let id = try read(fieldName) as Int? else { return nil }
    return Query<RecordType>().find(id)
  }
  
  /**
    This method reads a row from the database from an id fetched from another
    table.
   
    This has been deprecated in favor of converting the row to a serializable
    value using `serialize`, and then calling `read` on that value.
   
    - parameter fieldName:    The name of the field that contains the id.
    - returns:                The fetched record.
    - throws:                 A DatabaseError explaining why we couldn't fetch
    the record.
   */
  @available(*, deprecated, message="Use the `serialize` method and call `read` on the result")
  public func read<RecordType: Persistable>(fieldName: String) throws -> RecordType {
    guard let record = try self.read(fieldName) as RecordType? else {
      throw DatabaseError.MissingField(name: fieldName)
    }
    return record
  }
  
  /**
    This method reads an enum case from a row in the database.
   
    This has been deprecated in favor of converting the row to a serializable
    value using `serialize`, and then calling `read` on that value.
   
    - parameter fieldName:    The name of the field that contains the id.
    - returns:                The fetched value.
    - throws:                 A DatabaseError explaining why we couldn't fetch
                              the value.
   */
  @available(*, deprecated, message="Use the `serialize` method and call `read` on the result")
  public func readEnum<EnumType: TablePersistableEnum>(id fieldName: String) throws -> EnumType? {
    guard let id = try read(fieldName) as Int? else { return nil }
    return EnumType.fromId(id)
  }
  
  /**
    This method reads an enum case from a row in the database.
   
    This has been deprecated in favor of converting the row to a serializable
    value using `serialize`, and then calling `read` on that value.
   
    - parameter fieldName:    The name of the field that contains the id.
    - returns:                The fetched value.
    - throws:                 A DatabaseError explaining why we couldn't fetch
                              the value.
   */
  @available(*, deprecated, message="Use the `serialize` method and call `read` on the result")
  public func readEnum<EnumType: TablePersistableEnum>(id fieldName: String) throws -> EnumType {
    guard let record = try self.readEnum(id: fieldName) as EnumType? else {
      throw DatabaseError.MissingField(name: fieldName)
    }
    return record
  }
  
  /**
    This method reads an enum case from a row in the database.
   
    This has been deprecated in favor of converting the row to a serializable
    value using `serialize`, and then calling `read` on that value.
   
    - parameter fieldName:    The name of the field that contains the case name.
    - returns:                The fetched value.
    - throws:                 A DatabaseError explaining why we couldn't fetch
                              the value.
   */
  @available(*, deprecated, message="Use the `serialize` method and call `read` on the result")
  public func readEnum<EnumType: PersistableEnum>(name fieldName: String) throws -> EnumType? {
    guard let name = try read(fieldName) as String? else { return nil }
    return EnumType.fromCaseName(name)
  }
  
  
  /**
    This method reads an enum case from a row in the database.
   
    This has been deprecated in favor of converting the row to a serializable
    value using `serialize`, and then calling `read` on that value.
   
    - parameter fieldName:    The name of the field that contains the case name.
    - returns:                The fetched value.
    - throws:                 A DatabaseError explaining why we couldn't fetch
                              the value.
   */
  @available(*, deprecated, message="Use the `serialize` method and call `read` on the result")
  public func readEnum<EnumType: PersistableEnum>(name fieldName: String) throws -> EnumType {
    guard let record = try self.readEnum(name: fieldName) as EnumType? else {
      throw DatabaseError.MissingField(name: fieldName)
    }
    return record
  }
}

extension DatabaseRow: SerializationConvertible {
  /**
    This method creates a database row from the serialized values.
    
    - parameter values:   A serialized dictionary.
    - throws:             A `SerializationParsingError`, if the input is not a
                          dictionary.
    */
  public init(deserialize values: SerializableValue) throws {
    switch(values) {
    case let .Dictionary(values):
      self.init(data: values)
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Dictionary<String,SerializableValue>.self, caseType: values.wrappedType)
    }
  }
  
  /**
    This method serializes the data into a serialized dictionary.
    */
  public var serialize: SerializableValue {
    return .Dictionary(self.data)
  }
}