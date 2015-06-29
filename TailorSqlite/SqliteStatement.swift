import sqlite3
import Tailor

/**
  This class represents a prepared statement for a query.
  */
public final class SqliteStatement {
  /** The SQLite statement. */
  private let statement: COpaquePointer
  
  /** The SQLite connection. */
  private let connection: COpaquePointer
  
  /** The query. */
  private let query: String
  
  /**
    This method initializes a prepared statement.
  
    This will return nil if the SQLite API cannot prepare the statement.

    - parameter connection:   The SQLite connection.
    - parameter query:        The query.
    */
  public init?(connection: COpaquePointer, query: String) {
    self.connection = connection
    self.query = query
    var statement: COpaquePointer = nil
  
    let prepareResult = sqlite3_prepare_v2(connection, query, Int32(query.utf8.count), &statement, nil)
    if prepareResult != SQLITE_OK {
      print("Error preparing statement: \(prepareResult)")
      self.statement = nil
      return nil
    }
    self.statement = statement
  }
  
  /**
    This method fetches a value from a column in a returned result.

    - parameter column:   The column index that we are fetching, indexed from
                          one.
    - returns:            The parsed value.
    */
  private func fetchValue(column column: Int) -> DatabaseValue {
    let type = sqlite3_column_type(statement, Int32(column))
    let value: DatabaseValue
    switch(type) {
    case SQLITE_INTEGER:
      value = Int(sqlite3_column_int(statement, Int32(column))).databaseValue
    case SQLITE_TEXT:
      let characters = sqlite3_column_text(statement, Int32(column))
      let string = String.fromCString(UnsafePointer<CChar>(characters))
      value = string?.databaseValue ?? DatabaseValue.Null
    case SQLITE_NULL:
      value = DatabaseValue.Null
    default:
      print("Could not parse result type: \(type)")
      value = DatabaseValue.Null
    }
    return value
  }
  
  /**
    This method fetches a row from the returned result.
  
    This will only fetch the data. It will not advance the cursor.

    - returns:    The parsed row.
    */
  private func fetchRow() -> DatabaseRow {
    var data = [String:DatabaseValue]()
    let columnCount = Int(sqlite3_column_count(statement))
    
    for column in 0..<columnCount {
      let value = fetchValue(column: column)
      let nameBytes = sqlite3_column_name(statement, Int32(column))
      guard let name = String.fromCString(UnsafePointer<CChar>(nameBytes)) else { continue }
      data[name] = value
    }
    
    return DatabaseRow(data: data)
  }
  
  /**
    This method binds parameters to the inputs for this statement.

    - parameter parameters:   The parameters to bind.
    */
  public func bind(parameters: [DatabaseValue]) {
    for (index,parameter) in parameters.enumerate() {
      let column = Int32(index + 1)
      switch(parameter) {
      case let .Integer(int):
        sqlite3_bind_int(statement, column, Int32(int))
      case let .String(string):
        sqlite3_bind_text(statement, column, string, Int32(string.utf8.count), {_ in})
      case let .Timestamp(timestamp):
        let string = timestamp.format(TimeFormat.Database)
        sqlite3_bind_text(statement, column, string, Int32(string.utf8.count), {_ in })
      default:
        NSLog("Could not bind %@", parameter.description)
        continue
      }
    }
  }
  
  /**
    This method executes a query.
  
    If the query is an insert statement, this will return a row where the `id`
    column is mapped to the last inserted row ID. Otherwise it extracts and
    parses the values from the result set.

    - returns:    The rows that the query returned.
    */
  public func execute() -> [DatabaseRow] {
    var stepResult = sqlite3_step(statement)
    if stepResult != SQLITE_DONE && stepResult != SQLITE_ROW {
      print("Error executing query: \(stepResult)")
      return [DatabaseRow(error: "Error executing statement: \(stepResult)")]
    }
    
    var results = [DatabaseRow]()
    
    while stepResult == SQLITE_ROW {
      results.append(self.fetchRow())
      stepResult = sqlite3_step(statement)
    }
    
    if query.lowercaseString.hasPrefix("insert") {
      let id = sqlite3_last_insert_rowid(connection)
      return [DatabaseRow(rawData: ["id": Int(id)])]
    }
    
    return results
  }
  
  /**
    This method closes the statement.
  
    After this is called, the statement cannot be executed or modified again.
    */
  public func close() {
    sqlite3_finalize(statement)
  }
}
