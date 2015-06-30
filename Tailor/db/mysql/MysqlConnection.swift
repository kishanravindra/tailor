import Foundation
import mysql

/**
  This class represents a connection to a MySQL database.
  */
public final class MysqlConnection : DatabaseDriver {
  /** The underlying MySQL connection. */
  internal var connection : UnsafeMutablePointer<MYSQL>
  
  /** The time zone that the database is using. */
  public private(set) var timeZone: TimeZone
  
  /**
    This method initializes a connection to a MySQL database.

    - parameter config:   The config for the connection.
                          It must provide keys for host, username, password, and
                          database.
    */
  public init(config: [String:String]) {
    CONNECTION_INITIALIZATION_LOCK.lock()
    self.connection = mysql_init(nil)
    CONNECTION_INITIALIZATION_LOCK.unlock()
    self.timeZone = TimeZone.systemTimeZone()
    
    mysql_real_connect(self.connection, config["host"]!, config["username"]!, config["password"]!, config["database"]!,   0, nil, 0)
    
    let timeZoneInfo = self.executeQuery("SELECT @@session.time_zone as timeZone")
    if timeZoneInfo.count > 0 {
      let timeZoneDescription = timeZoneInfo[0].data["timeZone"]!.stringValue!
      let components = Request.extractWithPattern(timeZoneDescription, pattern: "([-+])(\\d\\d):(\\d\\d)")
      if components.count == 3 {
        let hour = Int(components[1])!
        let minute = Int(components[2])!
        var minutes = hour * 60 + minute
        if components[0] == "-" {
          minutes = minutes * -1
        }
        self.timeZone = TimeZone(offset: minutes * 60)
      }
      else {
        self.timeZone = TimeZone(name: timeZoneDescription)
      }
    }
  }
  
  /**
    This method deinitializes a connection.

    It will close and free the underlying MySQL connection.
    */
  deinit {
    mysql_close(connection)
  }
  
  //MARK - Queries
  
  /**
    This method executes a query against the database.
  
    If the query is a SELECT query, it will return the rows that were fetched.
    Otherwise, it will return a row with the last insert ID as the "id"
    column.
  
    - parameter query:            The text of the query.
    - parameter bindParameters:   Parameters to interpolate into the query on the
                                  database side.
    - returns:                    The interpreted result set.
    */
  public func executeQuery(query: String, parameters bindParameters: [DatabaseValue]) -> [DatabaseConnection.Row] {
    
    let stringParameters = bindParameters.map { $0.description }
    NSLog("Executing %@ %@", query, stringParameters)
    
    let statement = MysqlStatement(connection: self, query: query)
    
    if let error = statement.error {
      NSLog("Error in query: %@", error)
      return [DatabaseRow(error: error)]
    }
    
    let results = statement.execute(bindParameters)
    
    if let error = statement.error {
      NSLog("Error in query: %@", error)
      return [DatabaseRow(error: error)]
    }
    
    if let insertId = statement.insertId {
      return [DatabaseRow(rawData: ["id": insertId])]
    }
    
    return results.map { DatabaseRow(data: $0) }
  }

  //MARK: Transactions

  /**
    This method executes a block inside of a MySQL connection.

    - parameter block:   The block to execute.
    */
  public func transaction(block: ()->()) {
    mysql_query(self.connection, "START TRANSACTION;")
    block()
    mysql_query(self.connection, "COMMIT;")
  }
  
  //MARK: - Metadata
  
  /**
    This method gets the names of the tables in the database.
    */
  public func tableNames() -> [String] {
    let results = Application.sharedDatabaseConnection().executeQuery("SHOW TABLES")
    var filteredResults = [String]()
    for result in results {
      if let key = result.data.keys.first {
        if let tableName = result.data[key]?.stringValue {
          filteredResults.append(tableName)
        }
      }
    }
    return filteredResults
  }
}

private let CONNECTION_INITIALIZATION_LOCK = NSLock()