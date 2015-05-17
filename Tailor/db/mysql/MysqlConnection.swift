import Foundation
import mysql

/**
  This class represents a connection to a MySQL database.
  */
public class MysqlConnection : DatabaseConnection {
  /** The underlying MySQL connection. */
  public var connection : UnsafeMutablePointer<MYSQL>
  
  /**
    This method initializes a connection to a MySQL database.

    :param: config  The config for the connection.
                    It must provide keys for host, username, password, and
                    database.
    */
  public required init(config: [String:String]) {
    self.connection = mysql_init(nil)
    super.init(config: config)
    mysql_real_connect(self.connection, config["host"]!, config["username"]!, config["password"]!, config["database"]!,   0, nil, 0)
    
    let timeZoneInfo = self.executeQuery("SELECT @@session.time_zone as timeZone")
    if timeZoneInfo.count > 0 {
      let timeZoneDescription = timeZoneInfo[0].data["timeZone"]!.stringValue!
      let components = Request.extractWithPattern(timeZoneDescription, pattern: "([-+])(\\d\\d):(\\d\\d)")
      if components.count == 3 {
        let hour = components[1].toInt()!
        let minute = components[2].toInt()!
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
  
    :param: query           The text of the query.
    :param: bindParameters  Parameters to interpolate into the query on the
                            database side.
    :returns                The interpreted result set.
    */
  public override func executeQuery(query: String, parameters bindParameters: [DatabaseValue]) -> [DatabaseConnection.Row] {
    
    let stringParameters = bindParameters.map { $0.description }
    NSLog("Executing %@ %@", query, stringParameters)
    
    let statement = MysqlStatement(connection: self, query: query)
    
    if let error = statement.error {
      NSLog("Error in query: %@", error)
      return [Row(error: error)]
    }
    
    let results = statement.execute(bindParameters)
    
    if let error = statement.error {
      NSLog("Error in query: %@", error)
      return [Row(error: error)]
    }
    
    if let insertId = statement.insertId {
      return [Row(rawData: ["id": insertId])]
    }
    
    return results.map { Row(data: $0) }
  }

  //MARK: Transactions

  /**
    This method executes a block inside of a MySQL connection.

    :param: block   The block to execute.
    */
  public override func transaction(block: ()->()) {
    mysql_query(self.connection, "START TRANSACTION;")
    block()
    mysql_query(self.connection, "COMMIT;")
  }
}