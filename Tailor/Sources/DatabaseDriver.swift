import Foundation

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
  func executeQuery(query: String, parameters bindParameters: [SerializableValue]) -> [DatabaseRow]
  
  /**
    This method executes a block within a transaction.
    
    The default implementation wraps the block in queries for
    `START TRANSACTION` and `COMMIT`
  
    - parameter block:   The block to execute.
    */
   func transaction<T>(@noescape block: () throws ->T) rethrows -> T
  
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
  public func executeQuery(query: String, _ bindParameters: SerializationEncodable...) -> [DatabaseRow] {
    return self.executeQuery(query, parameterValues: bindParameters)
  }
  
  /**
    This method executes a query and returns a result set.
    
    - parameter query:            The text of the query.
    - parameter bindParameters:   Parameters to interpolate into the query on
    the database side.
    - returns:                    The interpreted result set.
    */
  public func executeQuery(query: String, parameterValues bindParameters: [SerializationEncodable]) -> [DatabaseRow] {
    let wrappedParameters = bindParameters.map { $0.serialize }
    return executeQuery(query, parameters: wrappedParameters)
  }
  
  /**
    This method executes a block within a transition.
    
    - parameter block:   The block to execute.
    */
  public func transaction<T>(@noescape block: Void throws -> T) rethrows -> T {
    executeQuery("START TRANSACTION;")
    let value = try block()
    executeQuery("COMMIT;")
    return value
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
  This enum holds errors that are thrown by methods for communicating with the
  database, or extracting data from a database result.
 
  This has been deprecated in favor of the SerializationParsingError errors.
  */
@available(*, deprecated, message="Use SerializationParsingError instead")
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