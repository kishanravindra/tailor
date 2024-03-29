import CSqlite
import Tailor
import Foundation

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
  private func fetchValue(column column: Int) -> SerializableValue {
    let type = sqlite3_column_type(statement, Int32(column))
    let value: SerializableValue
    switch(type) {
    case SQLITE_INTEGER:
      value = Int(sqlite3_column_int(statement, Int32(column))).serialize
    case SQLITE_TEXT:
      let characters = sqlite3_column_text(statement, Int32(column))
      let string = String.fromCString(UnsafePointer<CChar>(characters))
      value = string?.serialize ?? SerializableValue.Null
    case SQLITE_NULL:
      value = SerializableValue.Null
    case SQLITE_FLOAT:
      let double = sqlite3_column_double(statement, Int32(column))
      value = SerializableValue.Double(double)
    case SQLITE_BLOB:
      let size = sqlite3_column_bytes(statement, Int32(column))
      let bytes = sqlite3_column_blob(statement, Int32(column))
      let data = NSData(bytes: bytes, length: Int(size))
      value = SerializableValue.Data(data)
    default:
      print("Could not parse result type: \(type)")
      value = SerializableValue.Null
    }
    return value
  }
  
  /**
    This method fetches a row from the returned result.
  
    This will only fetch the data. It will not advance the cursor.

    - returns:    The parsed row.
    */
  private func fetchRow() -> DatabaseRow {
    var data = [String:SerializableValue]()
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
    This method binds a string to an input parameter.
    */
  public func bindString(string: String, at column: Int32) {
    let data: NSData
    if string == "" {
      data = NSData(bytes: [0])
    }
    else {
      data = NSData(bytes: string.utf8)
    }
    sqlite3_bind_text(statement, column, UnsafePointer<CChar>(data.bytes), Int32(data.length), {_ in})
  }
  
  /**
    This method binds parameters to the inputs for this statement.

    - parameter parameters:   The parameters to bind.
    */
  public func bind(parameters: [SerializableValue]) {
    for (index,parameter) in parameters.enumerate() {
      let column = Int32(index + 1)
      switch(parameter) {
      case let .Integer(int):
        sqlite3_bind_int(statement, column, Int32(int))
      case let .String(string):
        bindString(string, at: column)
      case let .Timestamp(timestamp):
        let string = timestamp.format(TimeFormat.Database)
        bindString(string, at: column)
      case let .Time(time):
        let timestamp = Timestamp.now().change(hour: time.hour, minute: time.minute, second: time.second)
        let string = timestamp.format(TimeFormat(.Hour, ":", .Minute, ":", .Seconds))
        bindString(string, at: column)
      case let .Date(date):
        let timestamp = date.beginningOfDay(Application.sharedDatabaseConnection().timeZone)
        let string = timestamp.format(TimeFormat(.Year, "-", .Month, "-", .Day))
        bindString(string, at: column)
      case .Null:
        sqlite3_bind_null(statement, column)
      case let .Double(double):
        sqlite3_bind_double(statement, column, double)
      case let .Data(data):
        if data.length == 0 {
          sqlite3_bind_blob(statement, column, "", Int32(data.length), {_ in })
        }
        else {
          sqlite3_bind_blob(statement, column, data.bytes, Int32(data.length), {_ in })
        }
      case let .Boolean(boolean):
        sqlite3_bind_int(statement, column, Int32(boolean ? 1 : 0))
        continue
      case .Array: continue
      case .Dictionary: continue
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
