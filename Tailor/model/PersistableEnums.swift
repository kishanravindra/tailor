/**
  This protocol is describes an enum that can be persisted in the database.

  You shouldn't implement this protocol directly. Instead, you should implement
  `StringPersistableEnum` or `TablePersistableEnum`.
  */
public protocol PersistableEnum: DatabaseValueConvertible {
  /**
    This method gets the name of a case of an enum.
  
    The default value uses the underscored version of the raw value for the
    case.
    */
  var caseName: String { get }
  
  /** This method gets all of the cases in the enum. */
  static var cases: [Self] { get }
  
  /**
    This method gets an enum case from a database value.
  
    - parameter databaseValue:    The value from the database.
    - returns                     The enum case
    */
  static func fromDatabaseValue(databaseValue: DatabaseValue?) -> Self?
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
public protocol TablePersistableEnum: PersistableEnum, ModelType {
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
}

public extension StringPersistableEnum {
  /**
    This method creates an enum case from a database value.
    
    This interprets the database value as the case name, and looks for a case
    with that case name.

    - parameter databaseValue:    The case name.
    - returns:                    The matching case.
    */
  static func fromDatabaseValue(databaseValue: DatabaseValue?) -> Self? {
    if let caseName = databaseValue?.stringValue {
      return self.fromCaseName(caseName)
    }
    else {
      return nil
    }
  }
  
  /**
    This method gets a database value for this enum case.

    This will just be the case name.
    */
  var databaseValue: DatabaseValue {
    return self.caseName.databaseValue
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
    let name = result[0].data["name"]
    return name?.stringValue
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
    This method creates an enum case from a database value.
    
    This interprets an id, and tries to find a case with that id.
    
    - parameter databaseValue:    The case id.
    - returns:                    The matching case.
    */
  static func fromDatabaseValue(databaseValue: DatabaseValue?) -> Self? {
    guard let id = databaseValue?.intValue else { return nil }
    return self.fromId(id)
  }
  
  /**
    This method gets the id in the lookup table that maps to this case.

    This will insert a new record if there is not a matching record.

    This will always return a value, unless the table does not have the
    necessary structure to support the protocol.
    */
  var id: Int? {
    let connection = Application.sharedDatabaseConnection()
    let tableName = self.dynamicType.tableName
    let caseName = self.caseName
    var result = connection.executeQuery("SELECT * FROM \(tableName) WHERE name=?", caseName)
    if result.isEmpty {
      result = connection.executeQuery("INSERT INTO \(tableName) (name) VALUES (?)", caseName)
      if result.isEmpty {
        return nil
      }
    }
    return result[0].data["id"]?.intValue
  }
  
  /**
    This method gets a database value for this case.

    This just be the id.
    */
  var databaseValue: DatabaseValue {
    return self.id?.databaseValue ?? .Null
  }
}