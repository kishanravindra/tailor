import CSqlite
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
  
    - parameter path:   The path to the file.
    */
  public init(path: String) {
    self.timeZone = TimeZone.systemTimeZone()
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
  public func executeQuery(query: String, parameters bindParameters: [SerializableValue]) -> [DatabaseRow] {
    if Application.configuration.logQueries {
      print("Executing query " + query)
    }
    guard let statement = SqliteStatement(connection: connection, query: query) else { return [DatabaseRow(error: "Error preparing statement")] }
    statement.bind(bindParameters)
    let results = statement.execute()
    statement.close()
    return results
  }
  
  /**
    This method gets the names of the tables in the database.
    */
  public func tables() -> [String:String] {
    let tableInfo = executeQuery("SELECT distinct tbl_name,sql FROM sqlite_master WHERE type='table'")
    var results = [String:String]()
    for table in tableInfo {
      if let tableNameValue = table.data["tbl_name"], sqlValue = table.data["sql"],
        tableName = try? String(deserialize: tableNameValue), sql = try? String(deserialize: sqlValue)
      {
          results[tableName] = sql
      }
    }
    return results
  }
}