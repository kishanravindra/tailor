import Foundation

/**
  This class represents a connection to a MySQL database.
  */
class MysqlConnection : DatabaseConnection {
  /**
    This class represents a row fetched from a MySQL daatabase. */
  class MysqlRow : DatabaseConnection.Row {
    /**
      This method initializes a row from a MySQL result.

      :param: metadata      The metadata about the result set.
      :param: bindResults   The containers for the result columns.
      */
    convenience init(metadata: UnsafeMutablePointer<MYSQL_RES>, bindResults: [MYSQL_BIND]) {
      var data : [String:Any] = [:]
      
      for (index,bindResult) in enumerate(bindResults) {
        let fieldType = mysql_fetch_field_direct(metadata, UInt32(index)).memory
        let name = NSString(bytes: fieldType.name, length: Int(fieldType.name_length), encoding: NSASCIIStringEncoding)

        NSLog("Name is %@", name)
        if let value = MysqlRow.extractBindResult(bindResult, type: fieldType.type) {
          data[name] = value
        }
      }
      self.init(data: data)
    }
    
    /**
      This method creates a bind container for a query result.
    
      This will dynamically allocate space for the buffer as well as the
      containers for the length, is_null, and error fields. The recipient will
      have to free those.

      :param: type    The type of the column.
      :returns:       The container.
      */
    class func createBindResult(type: enum_field_types) -> MYSQL_BIND {
      var bind = empty_mysql_bind_param()
      
      var bufferType = type
      var unitSize = sizeof(UInt8)
      var count = 1
      
      switch type.value {
      case MYSQL_TYPE_TINY.value:
        unitSize = sizeof(CChar)
      case MYSQL_TYPE_SHORT.value:
        unitSize = sizeof(CShort)
      case MYSQL_TYPE_LONG.value, MYSQL_TYPE_INT24.value:
        unitSize = sizeof(CInt)
      case MYSQL_TYPE_LONGLONG.value:
        unitSize = sizeof(CLongLong)
      case MYSQL_TYPE_FLOAT.value:
        unitSize = sizeof(CFloat)
      case MYSQL_TYPE_DOUBLE.value:
        unitSize = sizeof(CDouble)
      case MYSQL_TYPE_TIME.value, MYSQL_TYPE_DATE.value,
      MYSQL_TYPE_DATETIME.value, MYSQL_TYPE_TIMESTAMP.value:
        unitSize = sizeof(MYSQL_TIME)
      default:
        bufferType = MYSQL_TYPE_STRING
        count = 1024
      }
      
      var buffer = calloc(UInt(count), UInt(unitSize))
      bind.buffer = buffer
      bind.buffer_type = bufferType
      bind.buffer_length = UInt(count)
      
      bind.length = UnsafeMutablePointer<UInt>(malloc(UInt(sizeof(Int))))
      bind.is_null = UnsafeMutablePointer<my_bool>(malloc(UInt(sizeof(my_bool))))
      bind.error = UnsafeMutablePointer<my_bool>(malloc(UInt(sizeof(my_bool))))
      
      return bind
    }
    
    /**
      This method gets the data from a bind container for a result.

      :param: bindResult  The result container.
      :param: type        The type of the data that we are fetching.
      :returns:           The data in a native Swift format.
      */
    class func extractBindResult(bindResult: MYSQL_BIND, type: enum_field_types) -> Any? {
      if bindResult.is_null.memory != 0 {
        return nil
      }
      switch type.value {
      case MYSQL_TYPE_TINY.value:
        let buffer = UnsafeMutablePointer<CChar>(bindResult.buffer)
        return Int(buffer.memory)
      case MYSQL_TYPE_SHORT.value:
        let buffer = UnsafeMutablePointer<CShort>(bindResult.buffer)
        return Int(buffer.memory)
      case MYSQL_TYPE_LONG.value, MYSQL_TYPE_INT24.value:
        let buffer = UnsafeMutablePointer<CInt>(bindResult.buffer)
        return Int(buffer.memory)
      case MYSQL_TYPE_LONGLONG.value:
        let buffer = UnsafeMutablePointer<CLongLong>(bindResult.buffer)
        return Int(buffer.memory)
      case MYSQL_TYPE_FLOAT.value:
        let buffer = UnsafeMutablePointer<CFloat>(bindResult.buffer)
        return Int(buffer.memory)
      case MYSQL_TYPE_DOUBLE.value:
        let buffer = UnsafeMutablePointer<CDouble>(bindResult.buffer)
        return Int(buffer.memory)
      case MYSQL_TYPE_TIME.value, MYSQL_TYPE_DATE.value,
      MYSQL_TYPE_DATETIME.value, MYSQL_TYPE_TIMESTAMP.value:
        let buffer = UnsafeMutablePointer<MYSQL_TIME>(bindResult.buffer)
        let time = buffer.memory
        return NSDate(year: Int(time.year), month: Int(time.month),
          day: Int(time.day), hour: Int(time.hour), minute: Int(time.minute),
          second: Int(time.second))
      default:
        return NSString(bytes: bindResult.buffer, length: Int(bindResult.length.memory), encoding: NSUTF8StringEncoding)
      }
    }
  }
  
  /** The underlying MySQL connection. */
  var connection : UnsafeMutablePointer<MYSQL>
  
  /**
    This method initializes a connection to a MySQL database.

    :param: config  The config for the connection.
                    It must provide keys for host, username, password, and
                    database.
    */
  required init(config: [String:String]) {
    self.connection = mysql_init(nil)
    super.init(config: config)
    mysql_real_connect(self.connection, config["host"]!, config["username"]!, config["password"]!, config["database"]!,   0, nil, 0)
  }
  
  /**
    This method deinitializes a connection.

    It will close and free the underlying MySQL connection.
    */
  deinit {
    mysql_close(connection)
    free(connection)
  }
  
  //MARK - Queries
  
  /**
    This method executes a query against the database.
  
  
    :param: query           The text of the query.
    :param: bindParameters  Parameters to interpolate into the query on the
                            database side.
    :returns                The interpreted result set.
    */
  override func executeQuery(query: String, _ bindParameters: String...) -> [DatabaseConnection.Row] {
    let statement = mysql_stmt_init(connection)
    let encodedQuery = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    mysql_stmt_prepare(statement, UnsafePointer<Int8>(encodedQuery.bytes), UInt(encodedQuery.length))
    
    let metadataResult = mysql_stmt_result_metadata(statement)

    var mysqlBindParameters = bindParameters.map {
      (stringParameter: String) -> MYSQL_BIND in
      var buffer : [UInt8] = []
      let data = NSMutableData(data: stringParameter.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
      var bind = empty_mysql_bind_param()
      bind.buffer = UnsafeMutablePointer<Void>(data.mutableBytes)
      bind.buffer_length = UInt(data.length)
      bind.buffer_type = MYSQL_TYPE_STRING
      return bind
    }
    
    mysql_stmt_bind_param(statement, &mysqlBindParameters)
    mysql_stmt_execute(statement)
    
    mysqlBindParameters = []
    
    for index in 0..<mysql_num_fields(metadataResult) {
      let fieldType = mysql_fetch_field_direct(metadataResult, UInt32(index)).memory
      mysqlBindParameters.append(MysqlRow.createBindResult(fieldType.type))
    }
    
    mysql_stmt_bind_result(statement, &mysqlBindParameters)
    
    var rows : [MysqlRow] = []
    
    while mysql_stmt_fetch(statement) == 0 {
      let buffer = UnsafeMutablePointer<UInt32>(mysqlBindParameters[0].buffer)
      let row = MysqlRow(metadata: metadataResult, bindResults: mysqlBindParameters)
      rows.append(row)
    }
    
    for bindParameter in mysqlBindParameters {
      free(bindParameter.buffer)
      free(bindParameter.is_null)
      free(bindParameter.length)
      free(bindParameter.error)
    }
    
    mysql_free_result(metadataResult)
    mysql_stmt_close(statement)
    
    return rows
  }
}