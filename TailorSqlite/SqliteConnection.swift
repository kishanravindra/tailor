import sqlite3
import Tailor

/**
  This class provides a connection to a SQLite database.
  */
public final class SqliteConnection: DatabaseDriver {
  /** The database's time zone. */
  public let timeZone: TimeZone
  
  /** The SQLite connection. */
  private let connection: COpaquePointer
  
  /**
    This method initializes a connection to a SQLite database.
  
    The configuration must provide a `path` key with a path to the database
    file.

    - parameter config:   The configuration for the connection.
    */
  public init(config: [String: String]) {
    self.timeZone = TimeZone.systemTimeZone()
    guard let path = config["path"] else { fatalError("Could not create sqlite connection with no path") }
    var connection: COpaquePointer = nil
    let result = sqlite3_open(path, &connection)
    if result != SQLITE_OK {
      fatalError("Could not open sqlite connection: \(result)")
    }
    self.connection = connection
  }
  
  deinit {
    let result = sqlite3_close(connection)
    if result != SQLITE_OK {
      print("Error closing connection: \(result)")
    }
  }
  
  /**
    This method executes a query against the database.

    - parameter query:        The query to execute
    - parameter parameters:   The parameters to bind to the inputs to the query.
    */
  public func executeQuery(query: String, parameters bindParameters: [DatabaseValue]) -> [DatabaseRow] {
    NSLog("Executing query %@", query)
    guard let statement = SqliteStatement(connection: connection, query: query) else { return [DatabaseRow(error: "Error preparing statement")] }
    statement.bind(bindParameters)
    let results = statement.execute()
    statement.close()
    return results
  }
  
  /**
    This method gets the names of the tables in the database.
    */
  public func tableNames() -> [String] {
    let results = executeQuery("SELECT * FROM sqlite_master")
    return removeNils(results.map {
      return $0.data["tbl_name"]?.stringValue
    })
  }
}