import Foundation

/**
  This method provides an abstract base class for managing database connections
  and executing queries.

  **NOTE**: This class has been deprecated in favor of the DatabaseDriver
  protocol.
  */
@available(*, deprecated, message="Use the DatabaseDriver protocol instead") public class DatabaseConnection: DatabaseDriver {
  public typealias Row = DatabaseRow
  
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
    return Application.sharedApplication().openDatabaseConnection() as! DatabaseConnection
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
      let connection = self.openSharedConnection()
      dictionary["databaseConnection"] = connection
      return connection
    }
  }

  //MARK: - Queries

  
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
  
  /**
    This method gets a mapping of the names of the tables in the database to the
    SQL for creating them.
    */
  public func tables() -> [String:String] {
    return [:]
  }
}