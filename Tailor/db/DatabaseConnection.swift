import Foundation

/**
  This method provides an abstract base class for managing database connections
  and executing queries.
  */
public class DatabaseConnection {
  /**
    This class provides a base class for representing a row that is returned
    from a database query.
    */
  public class Row {
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
    public convenience init(rawData: [String:DatabaseValueConvertible]) {
      var wrappedData = [String:DatabaseValue]()
      for (key,value) in rawData {
        wrappedData[key] = value.databaseValue
      }
      self.init(data: wrappedData)
    }
    
    /**
      This method initializees a row for an error message.
      */
    public convenience init(error: String) {
      self.init(data: [:])
      self.error = error
    }
  }
  
  /** The time zone that the database is using. */
  public internal(set) var timeZone: TimeZone

  /**
    This method creates the connection.

    This will open the connection and do everything necessary to prepare for
    query execution.
    */
  public required init(config: [String:String]) {
    self.timeZone = TimeZone.systemTimeZone()
  }
  
  /**
    This forces us to open a new connection to serve as the shared connection.
    */
  public class func openSharedConnection() -> DatabaseConnection {
    let dictionary = NSThread.currentThread().threadDictionary
    let connection = Application.sharedApplication().openDatabaseConnection()
    dictionary["databaseConnection"] = connection
    return connection
  }
  
  /**
    This gets the shared global database connection.
    */
  public class func sharedConnection() -> DatabaseConnection {
    let dictionary = NSThread.currentThread().threadDictionary
    if let connection = dictionary["databaseConnection"] as? DatabaseConnection {
      return connection
    }
    else {
      return self.openSharedConnection()
    }
  }

  //MARK: - Queries

  /**
    This method executes a query and returns a result set.
    
    - parameter query:            The text of the query.
    - parameter bindParameters:   Parameters to interpolate into the query on
                                  the database side.
    :returns                      The interpreted result set.
    */
  public func executeQuery(query: String, _ bindParameters: DatabaseValueConvertible...) -> [Row] {
    return self.executeQuery(query, parameterValues: bindParameters)
  }
  
  /**
    This method executes a query and returns a result set.
    
    - parameter query:            The text of the query.
    - parameter bindParameters:   Parameters to interpolate into the query on
                                  the database side.
    - returns:                    The interpreted result set.
  */
  public func executeQuery(query: String, parameterValues bindParameters: [DatabaseValueConvertible]) -> [Row] {
    let wrappedParameters = bindParameters.map { $0.databaseValue }
    return executeQuery(query, parameters: wrappedParameters)
  }
  
  /**
  This method executes a query and returns a result set.
  
  - parameter query:            The text of the query.
  - parameter bindParameters:   Parameters to interpolate into the query on the
                                database side.
  - returns:                    The interpreted result set.
  */
  public func executeQuery(query: String, parameters bindParameters: [DatabaseValue]) -> [Row] {
    return []
  }
  
  /**
    This method sanitizes a column name so that it can be safely interpolated
    into a query.

    - parameter columnName:     The unsanitized version
    - returns:                  The sanitized version.
    */
  public class func sanitizeColumnName(columnName: String) -> String {
    let keyRegex = try! NSRegularExpression(pattern: "[^A-Za-z_0-9]", options: [])
    let range = NSMakeRange(0, columnName.characters.count)
    let sanitizedColumn = keyRegex.stringByReplacingMatchesInString(columnName, options: [], range: range, withTemplate: "")
    return sanitizedColumn
  }
  
  //MARK: Transactions
  
  /**
    This method executes a block within a transaction on the shared connection.
  
    - parameter block:   The block to execute.
    */
  public class func transaction(block: ()->()) {
    self.sharedConnection().transaction(block)
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
}