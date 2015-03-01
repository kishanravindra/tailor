import Foundation

/**
  This class represents a connection to a MySQL database.
  */
public class MysqlConnection : DatabaseConnection {
  /**
    This class represents a row fetched from a MySQL daatabase. */
  class MysqlRow : DatabaseConnection.Row {
    /**
      This method initializes a row from a MySQL result.

      :param: metadata      The metadata about the result set.
      :param: bindResults   The containers for the result columns.
      */
    convenience init(metadata: UnsafeMutablePointer<MYSQL_RES>, bindResults: [BindParameter]) {
      var data : [String:Any] = [:]
      
      for (index,bindResult) in enumerate(bindResults) {
        let fieldType = mysql_fetch_field_direct(metadata, UInt32(index)).memory

        let name = NSString(bytes: fieldType.name, length: Int(fieldType.name_length), encoding: NSASCIIStringEncoding)
        
        if name == nil {
          continue
        }

        if let value: AnyObject = bindResult.data() {
          data[name! as! String] = value
        }
      }
      
      self.init(data: data)
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
  public required init(config: [String:String]) {
    self.connection = mysql_init(nil)
    super.init(config: config)
    mysql_real_connect(self.connection, config["host"]!, config["username"]!, config["password"]!, config["database"]!,   0, nil, 0)
    
    let timeZoneInfo = self.executeQuery("SELECT @@session.time_zone as timeZone")
    if timeZoneInfo.count > 0 {
      let timeZoneDescription = timeZoneInfo[0].data["timeZone"] as! String
      let components = Request.extractWithPattern(timeZoneDescription, pattern: "([-+])(\\d\\d):(\\d\\d)")
      if components.count == 3 {
        let hour = components[1].toInt()!
        let minute = components[2].toInt()!
        var minutes = hour * 60 + minute
        if components[0] == "-" {
          minutes = minutes * -1
        }
        self.timeZone = NSTimeZone(forSecondsFromGMT: minutes * 60)
      }
      else if let zone = NSTimeZone(name: timeZoneDescription) {
        self.timeZone = zone
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
  public override func executeQuery(query: String, parameters bindParameters: [NSData]) -> [DatabaseConnection.Row] {
    
    let stringParameters = bindParameters.map {
      NSString(data: $0, encoding: NSUTF8StringEncoding) ?? "<data>"
    }
    NSLog("Executing %@ %@", query, stringParameters)
    
    let statement = mysql_stmt_init(connection)
    let encodedQuery = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
    let hasPrepareError = mysql_stmt_prepare(statement, UnsafePointer<Int8>(encodedQuery.bytes), UInt(encodedQuery.length))
    
    if hasPrepareError != 0 {
      let errorPointer = mysql_stmt_error(statement)
      let error : String = (NSString(CString: errorPointer, encoding: NSUTF8StringEncoding) as? String) ?? ""
      if !error.isEmpty {
        NSLog("Error in query: %@", error)
        return [MysqlRow(error: error)]
      }
    }
    
    let metadataResult = mysql_stmt_result_metadata(statement)
    
    var inputParameters = BindParameterSet(data: bindParameters)
    inputParameters.bindToInputOfStatement(statement)
    var outputParameters = BindParameterSet(statement: statement)
    outputParameters.bindToOutputOfStatement(statement)
    mysql_stmt_execute(statement)
    
    let errorPointer = mysql_stmt_error(statement)
    let error : String = (NSString(CString: errorPointer, encoding: NSUTF8StringEncoding) as? String) ?? ""
    if !error.isEmpty {
      NSLog("Error in query: %@", error)
      return [MysqlRow(error: error)]
    }
    
    if metadataResult == nil {
      let insertId = mysql_stmt_insert_id(statement)
      return [DatabaseConnection.Row(data: ["id": Int(insertId)])]
    }
    
    var rows : [MysqlRow] = []
    
    let parameterList = outputParameters.parameters() as! [BindParameter]
    while mysql_stmt_fetch(statement) == 0 {
      let row = MysqlRow(metadata: metadataResult, bindResults: parameterList)
      rows.append(row)
    }
    
    mysql_free_result(metadataResult)
    mysql_stmt_close(statement)
    
    return rows
  }

  //MARK: Transactions

  public override func transaction(block: ()->()) {
    mysql_query(self.connection, "START TRANSACTION;")
    block()
    mysql_query(self.connection, "COMMIT;")
  }
}