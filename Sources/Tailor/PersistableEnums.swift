/**
  This protocol is describes an enum that can be persisted in the database.

  You shouldn't implement this protocol directly. Instead, you should implement
  `StringPersistableEnum` or `TablePersistableEnum`.
  */
public protocol PersistableEnum: SerializationEncodable {
  /**
    This method gets the name of a case of an enum.
  
    The default value uses the underscored version of the raw value for the
    case.
    */
  var caseName: String { get }
  
  /** This method gets all of the cases in the enum. */
  static var cases: [Self] { get }
  
  /**
    This method gets an enum case from a serialized value.
  
    - parameter value:    The serialized value.
    - returns             The enum case
    */
  static func fromSerializableValue(value: SerializableValue?) -> Self?
}

/**
  This protocol describes an enum that can be persisted to a string value in
  the database.

  The only method you need to implement for the protocol is the `cases`
  method. The protocol provides the rest.
  */
public protocol StringPersistableEnum: PersistableEnum {
}

/**
  This protocol describes an enum that can be persisted to an integer value
  in the database, which will be mapped to a foreign key holding all the
  possible enum cases.

  The only method you need to implement for the protocol is the `cases`
  method. The protocol provides the rest.

  This requires that the table has two columns: `id` and `name`. `id` must be
  an auto-incrementing primary key, and `name` must be a string column.
  */
public protocol TablePersistableEnum: PersistableEnum, Persistable {
  /**
    This method gets the name of the table that holds the cases for the enum.

    The default implementation gets the pluralized version of the table name.
    */
  static var tableName: String { get }
}

public extension PersistableEnum {
  /**
    This method gets the name of a case of an enum.
    
    The default value uses the underscored version of the string value for the
    case.
    */
  var caseName: String {
    return String(self).underscored()
  }
  
  /**
    This method creates an enum case from a case name.

    - parameter caseName:   The name of the case, from the database.
    - returns:              The case.
    */
  static func fromCaseName(caseName: String) -> Self? {
    for item in self.cases {
      if item.caseName == caseName {
        return item
      }
    }
    return nil
  }
  
  /**
    This method gets an enum case from a database value.
  
    This method has been deprecated in favor of `fromSerializableValue`.
    
    - parameter databaseValue:    The value from the database.
    - returns                     The enum case
    */
    @available(*, deprecated, message="Use fromSerializableValue instead")
  static func fromDatabaseValue(databaseValue: DatabaseValue?) -> Self? {
    return self.fromSerializableValue(databaseValue)
  }
  
  /**
    This method gets a database-serialized value fo this case.

    This has been deprecated in favor of the `serialize` method.
    */
  @available(*, deprecated, message="Use `serialize` instead")
  var databaseValue: DatabaseValue {
    return self.serialize
  }
}

public extension StringPersistableEnum {
  /**
    This method creates an enum case from a serialized value.
    
    This interprets the serialized value as the case name, and looks for a case
    with that case name.

    - parameter databaseValue:    The case name.
    - returns:                    The matching case.
    */
  static func fromSerializableValue(value: SerializableValue?) -> Self? {
    if let value2 = value, caseName = try? String(deserialize: value2) {
      return self.fromCaseName(caseName)
    }
    else {
      return nil
    }
  }
  
  /**
    This method gets a serialized value for this enum case.

    This will just be the case name.
    */
  var serialize: SerializableValue {
    return self.caseName.serialize
  }
}

public extension TablePersistableEnum {
  /**
    This method gets the name of the table where we save the enum cases.

    The default implementation uses the pluralized model name.
    */
  static var tableName: String {
    return self.modelName().pluralized
  }
  
  /**
    This method gets the case name that corresponds to an id.

    This will fetch a record from the table by id, and return its `name`
    parameter.

    - parameter id:   The id to fetch
    - returns:        The corresponding name.
    */
  static func caseNameForId(id: Int) -> String? {
    let connection = Application.sharedDatabaseConnection()
    var result = connection.executeQuery("SELECT * FROM \(tableName) WHERE id=?", id)
    
    if result.isEmpty { return nil }
    if let name = result[0].data["name"] {
      return try? String(deserialize: name)
    }
    else {
      return nil
    }
  }
  
  /**
    This method gets an enum case from an id.
  
    This will get the case name for the id from the database and then get the
    case whose name matches the case name.

    - parameter id:   The id
    - returns:        The case.
    */
  static func fromId(id: Int) -> Self? {
    guard let name = self.caseNameForId(id) else { return nil }
    return self.fromCaseName(name)
  }
  
  /**
    This method creates an enum case from a serialized value.
    
    This interprets an id, and tries to find a case with that id.
    
    - parameter value:    The case id.
    - returns:            The matching case.
    */
  static func fromSerializableValue(value: SerializableValue?) -> Self? {
    guard let id = try? (value ?? .Null).read() as Int else { return nil }
    return self.fromId(id)
  }
  
  /**
    This method gets the id in the lookup table that maps to this case.

    This will insert a new record if there is not a matching record.

    This will always return a value, unless the table does not have the
    necessary structure to support the protocol.
    */
  var id: UInt {
    let connection = Application.sharedDatabaseConnection()
    let tableName = self.dynamicType.tableName
    let caseName = self.caseName
    var result = connection.executeQuery("SELECT * FROM \(tableName) WHERE name=?", caseName)
    if result.isEmpty {
      result = connection.executeQuery("INSERT INTO \(tableName) (name) VALUES (?)", caseName)
      if result.isEmpty {
        return 0
      }
    }
    guard let value = result[0].data["id"] else { return 0 }
    guard let id = try? UInt(deserialize: value) else { return 0 }
    return id
  }
  
  /**
    This method gets a database value for this case.

    This just be the id.
    */
  var serialize: SerializableValue {
    return self.id.serialize
  }
  
  /**
    This method creates an enum case from a row in the database.
  
    - parameter databaseRow:    The row in the database.
    */
  init(deserialize values: SerializableValue) throws {
    self = try values.readEnumIndirect("name")
  }
  
  /**
    This method gets the values that we save in the database for an enum record.
    */
  func valuesToPersist() -> [String:SerializationEncodable?] {
    return ["name": caseName]
  }
}