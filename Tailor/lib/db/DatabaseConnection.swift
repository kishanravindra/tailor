import Foundation

/**
  This method provides an abstract base class for managing database connections
  and executing queries.

  :todo: Modelling class
  :todo: Inserts and updates
  :todo: Better time zone support.
  :todo: Storing database config in a file.
  :todo: Add helper methods for sanitization
  */
class DatabaseConnection {
  /**
    This class provides a base class for representing a row that is returned
    from a database query.
    */
  class Row {
    /** The data returned for the row. */
    let data: [String:Any]
    
    /**
      This method initializes a row with a hash of data.
    
      :param: row   The data for the row.
      */
    required init(data: [String:Any]) {
      self.data = data
    }
  }

  /**
    This method creates the connection.

    This will open the connection and do everything necessary to prepare for
    query execution.
    */
  required init(config: [String:String]) {
  }
  
  /**
    This gets the shared global database connection.
    */
  class func sharedConnection() -> DatabaseConnection! {
    return SHARED_DATABASE_CONNECTION
  }
  
  /**
    This method opens the shared database connection.
    
    :param: config    The config for opening the connection.
    */
  class func open(config: [String:String]) {
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
  func executeQuery(query: String, _ bindParameters: String...) -> [Row] {
    return self.executeQuery(query, parameters: bindParameters)
  }
  
  /**
  This method executes a query and returns a result set.
  
  :param: query           The text of the query.
  :param: bindParameters  Parameters to interpolate into the query on the
  database side.
  :returns                The interpreted result set.
  */
  func executeQuery(query: String, parameters bindParameters: [String]) -> [Row] {
    return []
  }
}

var SHARED_DATABASE_CONNECTION : DatabaseConnection?