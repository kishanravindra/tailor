import Foundation
import mysql

/**
  This class wraps around a MySQL statement and provides a simpler syntax for
  executing it.
  */
public class MysqlStatement {
  /**
    A connection to the database.

    This is never set. It's just here to work around a bug in the compiler.
    */
  private let connection: UnsafeMutablePointer<MYSQL>? = nil
  
  /**
    The statement we are executing.
    */
  private let statement: UnsafeMutablePointer<MYSQL_STMT>
  
  /**
    The metadata about the result set for the query.
    */
  public let resultSet: MysqlResultSet
  
  /**
    This method gets the id o fthe row that was inserted as a result of the
    query.
    */
  public var insertId: Int? {
    if resultSet.isEmpty {
      let statement = UnsafeMutablePointer<MYSQL_STMT>(self.statement)
      return Int(mysql_stmt_insert_id(statement))
    }
    else {
      return nil
    }
  }
  
  /**
    This method gets the error message that has been set on a MySQL statement.
  
    - parameter statement:   The statement that we are working with.
  */
  public var error: String? {
    let errorPointer = mysql_stmt_error(self.statement)
    let error = (NSString(CString: errorPointer, encoding: NSUTF8StringEncoding) as? String)
    if error != nil && error!.isEmpty {
      return nil
    }
    else {
      return error
    }
  }
  
  /**
    This method initializes a statement.

    - parameter connection:    The connection that will execute the statement.
    - parameter query:         The query that we will execute.
    */
  public init(connection: MysqlConnection, query: String) {
    self.statement = mysql_stmt_init(connection.connection)

    let encodedQuery = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    
    mysql_stmt_prepare(statement, UnsafePointer<Int8>(encodedQuery.bytes), UInt(encodedQuery.length))
    
    self.resultSet = MysqlResultSet(statement: self.statement)
  }
  
  /**
    This method deallocates the statement.

    It will close the underlying MySQL statement and free up the metadata.
    */
  deinit {
    mysql_stmt_close(statement)
  }
  
  /**
    This method executes the statement.

    - parameter parameters:     The values to pass to the statement.
    - returns:                  The results of executing the statement.
    */
  public func execute(parameters: [DatabaseValue]) -> [[String:DatabaseValue]] {
    let inputParameters = MysqlBindParameterSet(values: parameters)
    inputParameters.bindToInputOfStatement(self.statement)
    
    let outputParameterSet = MysqlBindParameterSet(resultSet: self.resultSet)
    outputParameterSet.bindToOutputOfStatement(self.statement)
    let outputParameters = outputParameterSet.parameters
    
    let hasError = mysql_stmt_execute(self.statement)
    
    if hasError != 0 {
      return []
    }
    
    let names = self.resultSet.fields.map { $0.name }
    var results = [[String:DatabaseValue]]()
    
    if names.isEmpty {
      return []
    }
    
    while mysql_stmt_fetch(self.statement) == 0 {
      var result = [String:DatabaseValue]()
      for (index,parameter) in outputParameters.enumerate() {
        result[names[index]] = parameter.data()
      }
      results.append(result)
    }
    return results
  }
}