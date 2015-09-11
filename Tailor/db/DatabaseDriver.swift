/**
  This protocol describes an interface to a database.
  */
public protocol DatabaseDriver: class {
  /** The time zone that the database is using. */
  var timeZone: TimeZone { get }
  
  /**
    This method executes a query and returns a result set.
    
    - parameter query:            The text of the query.
    - parameter bindParameters:   Parameters to interpolate into the query on
                                  the database side.
    - returns:                    The interpreted result set.
    */
  func executeQuery(query: String, parameters bindParameters: [DatabaseValue]) -> [DatabaseRow]
  
  /**
    This method executes a block within a transaction.
    
    The default implementation wraps the block in queries for
    `START TRANSACTION` and `COMMIT`
  
    - parameter block:   The block to execute.
    */
   func transaction(block: ()->())
  
  /**
    This method getes the tables in the database.
  
    This will be a dictionary mapping table names to the SQL for creating them.
    */
  func tables() -> [String:String]
}

public extension DatabaseDriver {
  //MARK: - Queries

  /**
    This method executes a query and returns a result set.
    
    - parameter query:            The text of the query.
    - parameter bindParameters:   Parameters to interpolate into the query on
                                  the database side.
    - returns:                    The interpreted result set.
    */
  public func executeQuery(query: String, _ bindParameters: DatabaseValueConvertible...) -> [DatabaseRow] {
    return self.executeQuery(query, parameterValues: bindParameters)
  }
  
  /**
    This method executes a query and returns a result set.
    
    - parameter query:            The text of the query.
    - parameter bindParameters:   Parameters to interpolate into the query on
    the database side.
    - returns:                    The interpreted result set.
    */
  public func executeQuery(query: String, parameterValues bindParameters: [DatabaseValueConvertible]) -> [DatabaseRow] {
    let wrappedParameters = bindParameters.map { $0.databaseValue }
    return executeQuery(query, parameters: wrappedParameters)
  }
  
  /**
    This method executes a block within a transition.
    
    - parameter block:   The block to execute.
    */
  public func transaction(block: ()->()) {
    executeQuery("START TRANSACTION;")
    block()
    executeQuery("COMMIT;")
  }
  
  /**
    This method sanitizes a column name so that it can be safely interpolated
    into a query.
    
    - parameter columnName:     The unsanitized version
    - returns:                  The sanitized version.
    */
  public func sanitizeColumnName(columnName: String) -> String {
    let keyRegex = try! NSRegularExpression(pattern: "[^A-Za-z_0-9]", options: [])
    let range = NSMakeRange(0, columnName.characters.count)
    let sanitizedColumn = keyRegex.stringByReplacingMatchesInString(columnName, options: [], range: range, withTemplate: "")
    return sanitizedColumn
  }
  
  /**
    This method gets the names of the tables in the database.
    */
  public func tableNames() -> [String] {
    return Array(self.tables().keys)
  }
}

/**
  This structure represents a row of data returned from the database.
  */
public struct DatabaseRow {
  /** The data returned for the row. */
  public let data: [String:DatabaseValue]
  
  /** The error message that the database gave for this query. */
  public private(set) var error: String?
  
  /**
    This method initializes a row with a hash of data.
    
    - parameter data:   The data for the row.
    */
  public init(data: [String:DatabaseValue]) {
    self.data = data
  }
  
  /**
    This method initializes a row with a hash of values that can be mapped
    to database values.
    
    - parameter rawData:   The unwrapped data.
    */
  public init(rawData: [String:DatabaseValueConvertible]) {
    var wrappedData = [String:DatabaseValue]()
    for (key,value) in rawData {
      wrappedData[key] = value.databaseValue
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
  
    - parameter key:    The key to read.
    - returns:          The cast value.
    - throws:           An exception from `DatabaseError`.
    */
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
  
    - parameter key:    The key to read.
    - returns:          The cast value.
    - throws:           An exception from `DatabaseError`.
    */
  public func read<OutputType: DatabaseValueConvertible>(key: String) throws -> OutputType? {
    guard let value = self.data[key] else { return nil }
    if value == .Null { return nil }
    if value == .String("") { return nil }
    let result: OutputType = try self.read(key)
    return result
  }
}

/**
  This enum holds errors that are thrown by methods for communicating with the
  database, or extracting data from a database result.
  */
public enum DatabaseError: ErrorType {
  /**
    This error is thrown when something goes wrong and we don't have a
    specialized error for it.
  
    - parameter message:    A message describing the error.
    */
  case GeneralError(message: String)
  
  /**
    This error is thrown when the user tries to read a value from a database
    row, but there is no value there.
  
    - parameter name:   The name of the field they tried to read.
    */
  case MissingField(name: String)
  
  /**
    This error is thrown when the user tries to read a value from a database
    row, but the actual value is not compatible with the requested type.
    */
  case FieldType(name: String, actualType: String, desiredType: String)
}

public extension Application {
  /**
    This gets the shared global database connection.
    */
  public static func sharedDatabaseConnection() -> DatabaseDriver {
    let dictionary = NSThread.currentThread().threadDictionary
    if let connection = dictionary["databaseConnection"] as? DatabaseDriver {
      return connection
    }
    else {
      guard let connection = Application.configuration.databaseDriver?() else {
        fatalError("Could not get database driver from config")
      }
      dictionary["databaseConnection"] = connection
      return connection
    }
  }
  
  /**
    This method clears the shared database connection, forcing the next call
    to `sharedDatabaseConnection` to open a new connection.
    */
  public static func removeSharedDatabaseConnection() {
    NSThread.currentThread().threadDictionary.removeObjectForKey("databaseConnection")
  }
}