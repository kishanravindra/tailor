import mysql

/**
  This class represents a list of parameters for a query.

  This can be either the input parameters or the output parameters.

  This class manages its own list of bind parameters, both the MySQL data
  structures and the wrappers we build around them. This will also do all the
  necessary memory management for the buffers for sending and retrieving the
  data.
  */
public final class MysqlBindParameterSet {
  /** The raw MySQL parameters. */
  public private(set) var mysqlParameters: [MYSQL_BIND];
  
  /** The parameters wrapped parameters. */
  public let parameters: [MysqlBindParameter];
  
  /**
    This method initializes a parameter set with no parameters.
    */
  public init() {
    mysqlParameters = []
    parameters = []
  }
  
  /**
    This method initializes a parameter set with input parameters.

    :param: values    The values for the input parameters.
    */
  public init(values: [DatabaseValue]) {
    var parameters = [MysqlBindParameter]()
    var mysqlParameters = [MYSQL_BIND]()
    
    for value in values {
      let parameter = MysqlBindParameter(value: value)
      parameters.append(parameter)
      mysqlParameters.append(parameter.parameter)
    }
    self.parameters = parameters
    self.mysqlParameters = mysqlParameters
  }
  
  /**
    This method initializes a parameter set to hold the values in a result
    set.

    :param: resultSet   The wrapped result set.
    */
  public init(resultSet: MysqlResultSet) {
    var parameters = [MysqlBindParameter]()
    var mysqlParameters = [MYSQL_BIND]()
    for field in resultSet.fields {
      let parameter = MysqlBindParameter(field: field)
      parameters.append(parameter)
      mysqlParameters.append(parameter.parameter)
    }
    
    self.parameters = parameters
    self.mysqlParameters = mysqlParameters
  }
  
  /**
    This method deallocates the parameter set.

    This will free all of the buffers from the bind parameters.
    */
  deinit {
    for parameter in mysqlParameters {
      free(parameter.buffer);
      free(parameter.is_null);
      free(parameter.length);
      free(parameter.error);
    }
  }
  
  /**
    This method binds these parameters to the input parameters for a query.

    :param: statement   The MySQL data structure for the query.
    */
  public func bindToInputOfStatement(statement: UnsafeMutablePointer<MYSQL_STMT>) {
    mysql_stmt_bind_param(statement, &mysqlParameters)
  }
  
  /**
    This method binds these parameterse to the output of a query.

    :param: statement   The MySQL data structure for the query.
    */
  public func bindToOutputOfStatement(statement: UnsafeMutablePointer<MYSQL_STMT>) {
    mysql_stmt_bind_result(statement, &mysqlParameters)
  }
}