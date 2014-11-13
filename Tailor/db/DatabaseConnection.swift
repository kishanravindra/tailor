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
    public let data: [String:Any]
    
    /** The error message that the database gave for this query. */
    public private(set) var error: String?
    
    /**
      This method initializes a row with a hash of data.
    
      :param: row   The data for the row.
      */
    public required init(data: [String:Any]) {
      self.data = data
    }
    
    /**
      This method initializees a row for an error message.
      */
    public convenience init(error: String) {
      self.init(data: [:])
      self.error = error
    }
  }
  
  public internal(set) var timeZone: NSTimeZone

  /**
    This method creates the connection.

    This will open the connection and do everything necessary to prepare for
    query execution.
    */
  public required init(config: [String:String]) {
    self.timeZone = NSTimeZone.systemTimeZone()
  }
  
  /**
    This gets the shared global database connection.
    */
  public class func sharedConnection() -> DatabaseConnection! {
    return SHARED_DATABASE_CONNECTION
  }
  
  /**
    This method opens the shared database connection.
    
    :param: config    The config for opening the connection.
    */
  public class func open(config: [String:String]) {
    SHARED_DATABASE_CONNECTION = self(config: config)
  }

  //MARK: - Queries

  /**
    This method executes a query and returns a result set.
    
    :param: query           The text of the query.
    :param: bindParameters  Parameters to interpolate into the query on the
                            database side.
    :returns                The interpreted result set.
    */
  public func executeQuery(query: String, _ bindParameters: String...) -> [Row] {
    return self.executeQuery(query, stringParameters: bindParameters)
  }
  
  /**
    This method executes a query and returns a result set.
    
    :param: query           The text of the query.
    :param: bindParameters  Parameters to interpolate into the query on the
                            database side.
    :returns                The interpreted result set.
  */
  public func executeQuery(query: String, stringParameters bindParameters: [String]) -> [Row] {
    NSLog("Executing %@ (%@)", query, bindParameters)
    let rawParameters = bindParameters.map { ($0 as NSString).dataUsingEncoding(NSUTF8StringEncoding)! }
    return executeQuery(query, parameters: rawParameters)
  }
  
  /**
  This method executes a query and returns a result set.
  
  :param: query           The text of the query.
  :param: bindParameters  Parameters to interpolate into the query on the
  database side.
  :returns                The interpreted result set.
  */
  public func executeQuery(query: String, parameters bindParameters: [NSData]) -> [Row] {
    return []
  }
  
  /**
    This method sanitizes a column name so that it can be safely interpolated
    into a query.

    :param: columnName    The unsanitized version
    :returns:             The sanitized version.
    */
  public class func sanitizeColumnName(columnName: String) -> String {
    let keyRegex = NSRegularExpression(pattern: "[^A-Za-z_0-9]", options: nil, error: nil)!
    let range = NSMakeRange(0, countElements(columnName))
    let sanitizedColumn = keyRegex.stringByReplacingMatchesInString(columnName, options: nil, range: range, withTemplate: "")
    return sanitizedColumn
  }
}

/** The connection to the database. */
var SHARED_DATABASE_CONNECTION : DatabaseConnection?