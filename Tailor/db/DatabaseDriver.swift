/**
  This protocol describes an interface to a database.
  */
public protocol DatabaseDriver: class {
  /** The time zone that the database is using. */
  var timeZone: TimeZone { get }
  
  
  /**
    This method creates the connection.
  
    This must open the connection and do everything necessary to prepare for
    query execution.
  
    This has been deprecated. Database drivers are encouraged to now provide
    initializers with explicit arguments.
    */
  @available(*, deprecated) init(config: [String:String])
  
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
  
  public func tableNames() -> [String] {
    return self.tables().keys.array
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
}