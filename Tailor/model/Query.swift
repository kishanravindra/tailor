import Foundation

/**
  This class represents a query to fetch records.

  It provides methods for building the query by method chaining.
  */
public class Query<RecordType: Record> {
  //MARK: - Structure
  
  /** A portion of a SQL query that contains a query and the bind parameters. */
  public typealias SqlFragment = (query: String, parameters: [String])
  
  /** The fields that the query will select. */
  public let selectClause: String
  
  /** The part of the query for filtering the result set. */
  public let whereClause: SqlFragment
  
  /** The part of the query for defining the order of the returned results. */
  public let orderClause: SqlFragment
  
  /** The part of the query for defining how many results should be returned. */
  public let limitClause: SqlFragment
  
  /** The part of the query for joining to other tables. */
  public let joinClause: SqlFragment
  
  /**
    The model-level conditions that are attached to this query.

    This is not used in querying, but is used in building new records.
    */
  public let conditions: [String:AnyObject?]
  
  /**
    This method builds a query from its component clause.

    :param: selectClause    The fields that will be selected.
    :param: whereClause     The portion of the query for filtering the result
                            set.
    :param: orderClause     The portion of the query specifying the order of the
                            returned results.
    :param: limitClause     The portion of the query specifying how many results
                            should be returned.
    */
  public required init(copyFrom: Query<RecordType>? = nil, selectClause: String? = nil, whereClause: SqlFragment? = nil, orderClause: SqlFragment? = nil, limitClause: SqlFragment? = nil, joinClause: SqlFragment? = nil, conditions: [String:AnyObject?]? = nil) {
    self.selectClause = selectClause ?? copyFrom?.selectClause ?? "\(RecordType.tableName()).*"
    self.whereClause = whereClause ?? copyFrom?.whereClause ?? ("", [])
    self.orderClause = orderClause ?? copyFrom?.orderClause ?? ("", [])
    self.limitClause = limitClause ?? copyFrom?.limitClause ?? ("", [])
    self.joinClause = joinClause ?? copyFrom?.joinClause ?? ("", [])
    self.conditions = conditions ?? copyFrom?.conditions ?? [:]
  }

  //MARK: - Query Building

  /**
    This method adds a filter clause based on raw SQL, and returns a new version
    of the query with the filter added.

    :param: query         The new clause for the query
    :param: parameters    The new bind parameters
    :returns:             The new query object.
    */
  public func filter(query: String, _ parameters: [String] = []) -> Query<RecordType> {
    var clause = whereClause
    
    if query.isEmpty {
      return self
    }
    
    if !clause.query.isEmpty {
      clause.query += " AND "
    }
    clause.query += query
    clause.parameters.extend(parameters)
    return self.dynamicType.init(
      copyFrom: self,
      whereClause: clause
    )
  }
  
  /**
    This method adds a filter clause based on a dictionary of conditions, and
    returns a new version of the query with the filter added.
  
    :param: conditions    The conditions, with keys matching field names on the
                          record type and values matching the field types on the
                          record type.
    :returns:             The new query object.
    */
  public func filter(conditions: [String: AnyObject?]) -> Query<RecordType> {
    var query = ""
    var parameters : [String] = []
    let tableName = RecordType.tableName()
    if !conditions.isEmpty {
      for (fieldName,value) in conditions {
        var columnName = RecordType.columnNameForField(fieldName)
        if fieldName == "id" {
          columnName = fieldName
        }
        if columnName != nil  {
          if !query.isEmpty {
            query += " AND "
          }
          
          if value != nil {
            let (stringValue, _) = RecordType.serializeValueForQuery(value, key: fieldName)
            if stringValue != nil {
              query += "\(tableName).\(columnName!)=?"
              parameters.append(stringValue!)
            }
          }
          else {
            query += "\(tableName).\(columnName!) IS NULL"
          }
        }
        else {
          NSLog("Error: Could not map %@.%@ to column", RecordType.modelName(), fieldName)
        }
      }
    }
    let mergedConditions = merge(conditions, self.conditions)
    return self.dynamicType.init(conditions: mergedConditions, copyFrom: self.filter(query, parameters))
  }
  
  /**
    This method attaches an ordering to the query, and returns the result.

    :param: fieldName   The name of the field to order by, using the field name
                        from the record type.
    :param: order       Whether to put the results in ascending or descending
                        order.
    :returns:           The new query.
    */
  public func order(fieldName: String, _ order: NSComparisonResult) -> Query<RecordType> {
    var columnName = RecordType.columnNameForField(fieldName)
    var clause = orderClause
    if columnName != nil {
      if !clause.query.isEmpty {
        clause.query += ", "
      }
      let orderDescription = order == .OrderedAscending ? "ASC" : "DESC"
      clause.query += "\(RecordType.tableName()).\(columnName!) \(orderDescription)"
    }
    else {
      NSLog("Error: Could not map %@.%@ to column", RecordType.modelName(), fieldName)
    }
    return self.dynamicType.init(
      copyFrom: self,
      orderClause: clause
    )
  }
  
  /**
    This method attaches a limit to the query, and returns a new query with that
    limit.

    If this limit is less than the existing limit, or if there is no existing
    limit, we will use the new limit. If this limit is more than the existing
    limit, we will keep using the existing limit.

    :param: limit     The limit to apply.
    :returns:         The new query.
    */
  public func limit(limit: Int) -> Query<RecordType> {
    var newLimit = limit
    if let oldLimit = self.limitClause.query.toInt() {
      if oldLimit < newLimit {
        newLimit = oldLimit
      }
    }
    var clause = limitClause
    clause.query = "\(newLimit)"
    return self.dynamicType.init(
      copyFrom: self,
      limitClause: clause
    )
  }
  
  /**
    This method specifies what fields from the database we should select with
    our query.

    :param: selectClause      The SQL for selecting the fields, not including
                              the SELECT keyword.
    :returns:                 The new query.
    */
  public func select(selectClause: String) -> Query<RecordType> {
    return self.dynamicType.init(
      copyFrom: self,
      selectClause: selectClause
    )
  }
  
  /**
    This method adds a join to the query.

    :param: query           The SQL for selecting the fields, including the JOIN
                            keywords.
    :param: parameters      The bind parameters to pass to the join statement.
    :returns:               The new query.
    */
  public func join(query: String, _ parameters: [String] = []) -> Query<RecordType> {
    var clause = self.joinClause
    
    if !clause.query.isEmpty {
      clause.query += " "
    }
    clause.query += query
    clause.parameters.extend(parameters)
    return self.dynamicType.init(
      copyFrom: self,
      joinClause: clause
    )
  }
  
  /**
    This method adds a join to the query.
  
    :param: recordType    The target record type for the join.
    :param: fromField     The field on the target record to match for the join.
    :param: toField       The field on this record to match for the join.
    :returns:             The new query.
  */
  public func join(recordType: Record.Type, fromField: String, toField: String) -> Query<RecordType> {
    let fromTable = recordType.tableName()
    let fromColumn = recordType.columnNameForField(fromField)
    let toTable = RecordType.tableName()
    let toColumn = RecordType.columnNameForField(toField)
    if fromColumn != nil && toColumn != nil {
      return self.join("INNER JOIN \(fromTable) ON \(fromTable).\(fromColumn!) = \(toTable).\(toColumn!)")
    }
    else {
      return self
    }
  }
  
  //MARK: - Running Query
  
  /**
    This method gets the full SQL for running this query.

    :returns: The SQL query and bind parameters.
    */
  public func toSql() -> SqlFragment {
    var query = "SELECT \(selectClause) FROM \(RecordType.tableName())"
    var parameters : [String] = []
    let clauses = [
      ("", joinClause),
      ("WHERE ", whereClause),
      ("ORDER BY ", orderClause),
      ("LIMIT ", limitClause)
    ]
    
    for (prefix, clause) in clauses {
      if !clause.query.isEmpty {
        query += " \(prefix)" + clause.query
        parameters.extend(clause.parameters)
      }
    }
    
    return (query, parameters)
  }
  
  /**
    This method runs the query and creates records from the result set.

    :returns:   The fetched records.
    */
  public func all() -> [RecordType] {
    let (query, parameters) = self.toSql()
    let results = DatabaseConnection.sharedConnection().executeQuery(query, stringParameters: parameters)
    let type = RecordType.self
    return results.map { type.init(data: $0.data, fromDatabase: true) }
  }
  
  /**
    This method runs the query, limiting it to 1 result, and returns that
    result.

    :returns:   The fetched record.
    */
  public func first() -> RecordType? {
    let results = self.limit(1).all()
    if results.count > 0 {
      return results[0]
    }
    else {
      return nil
    }
  }
 
  /**
    This method finds a record with an id.

    :returns:   The fetched record.
    */
  public func find(id: Int) -> RecordType? {
    return self.filter(["id": NSNumber(integer: id)]).first()
  }

  /**
    This method gets a count of the records matching the filterse in this query.
    
    :returns:   The count.
    */
  public func count() -> Int {
    let (query, parameters) = self.select("count(*) as tailor_record_count").toSql()
    let results = DatabaseConnection.sharedConnection().executeQuery(query, stringParameters: parameters)
    let count = results.isEmpty ? 0 : results[0].data["tailor_record_count"] as! Int
    return count
  }
  
  /**
    This method determines if the result set for this query is empty.

    :returns: Whether there are no results.
    */
  public func isEmpty() -> Bool {
    return self.count() == 0
  }
  
  //MARK: - Building Records
  
  /**
    This method builds a new record based on the conditions on this query.
  
    :param: data    The fields to set on the new record. Any conditions from
                    this query will be set automatically.
    :returns:       The new record
    */
  public func build(_ data: [String:Any] = [:]) -> RecordType {
    let type = RecordType.self
    let record = type.init(data: data)
    for (key,value) in conditions {
      var anyValue: Any? = nil
      switch(value) {
      case let object as NSObject:
        anyValue = object
      default:
        break
      }
      record.setValue(anyValue, forKey: key)
    }
    return record
  }
  
  
  /**
    This method creates a new record based on the conditions on this query.
  
    It will build the record using the build method and then save it.
  
    :param: data    The fields to set on the new record. Any conditions from
                    this query will be set automatically.
    :returns:       The new record
  */
  public func create(_ data: [String:Any] = [:]) -> RecordType {
    let record = self.build(data)
    record.save()
    return record
  }
}