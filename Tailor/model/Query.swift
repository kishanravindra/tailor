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
  
  /** Whether the query should cache its results. */
  public let cacheResults: Bool
  
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
  public required init(copyFrom: Query<RecordType>? = nil, selectClause: String? = nil, whereClause: SqlFragment? = nil, orderClause: SqlFragment? = nil, limitClause: SqlFragment? = nil, joinClause: SqlFragment? = nil, conditions: [String:AnyObject?]? = nil, cacheResults: Bool? = nil) {
    self.selectClause = selectClause ?? copyFrom?.selectClause ?? "\(RecordType.tableName()).*"
    self.whereClause = whereClause ?? copyFrom?.whereClause ?? ("", [])
    self.orderClause = orderClause ?? copyFrom?.orderClause ?? ("", [])
    self.limitClause = limitClause ?? copyFrom?.limitClause ?? ("", [])
    self.joinClause = joinClause ?? copyFrom?.joinClause ?? ("", [])
    self.conditions = conditions ?? copyFrom?.conditions ?? [:]
    self.cacheResults = cacheResults ?? copyFrom?.cacheResults ?? false
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
      for (columnName,value) in conditions {
        if !query.isEmpty {
          query += " AND "
        }
        
        if value != nil {
          let (stringValue, _) = RecordType.serializeValueForQuery(value, key: columnName)
          if stringValue != nil {
            query += "\(tableName).\(columnName)=?"
            parameters.append(stringValue!)
          }
        }
        else {
          query += "\(tableName).\(columnName) IS NULL"
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
  public func order(columnName: String, _ order: NSComparisonResult) -> Query<RecordType> {
    var clause = orderClause
    if !clause.query.isEmpty {
      clause.query += ", "
    }
    let orderDescription = order == .OrderedAscending ? "ASC" : "DESC"
    clause.query += "\(RecordType.tableName()).\(columnName) \(orderDescription)"
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
  public func join(recordType: Record.Type, fromColumn: String, toColumn: String) -> Query<RecordType> {
    let fromTable = recordType.tableName()
    let toTable = RecordType.tableName()
    return self.join("INNER JOIN \(fromTable) ON \(fromTable).\(fromColumn) = \(toTable).\(toColumn)")
  }

  /**
    This method reverses the order of a query.

    If the query has no order clause, it will order the query in descending
    order by id.

    :returns:   The new query.
    */
  public func reverse() -> Query<RecordType> {
    var orderClause = self.orderClause
    if orderClause.query.isEmpty {
      orderClause.query = "id DESC"
    }
    else {
      var components = split(orderClause.query) { $0 == "," }
      components = components.map {
        component in
        var reversed = component
        if reversed.uppercaseString.hasSuffix("ASC") {
          reversed = reversed.stringByReplacingOccurrencesOfString(" ASC", withString: " DESC", options: .CaseInsensitiveSearch)
        }
        else {
          reversed = reversed.stringByReplacingOccurrencesOfString(" DESC", withString: " ASC", options: .CaseInsensitiveSearch)
        }
        return reversed
      }
      orderClause.query = ",".join(components)
    }
    return self.dynamicType.init(copyFrom: self, orderClause: orderClause)
  }
  
  /**
    This method gets a version of this query with caching turned on.

    When caching is turned on, the ids of the results of this query will be
    stored in the cache. The cache key will contain the query string and the
    parameters. Subsequent attempts to fetch records will get the ids out of
    the cache and fetch the records by id rather than running the query.

    :returns:   The query with caching turned on.
    */
  public func cached() -> Query<RecordType> {
    return self.dynamicType.init(copyFrom: self, cacheResults: true)
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
    if self.cacheResults {
      let parameterString = ",".join(parameters)
      let cacheKey = query + "(" + parameterString + ")"
      
      var idString = CacheStore.shared().read(cacheKey)
      if idString != nil && !idString!.matches("[0-9,]*") {
        idString = nil
      }
      
      if idString == nil {
        let results = self.dynamicType.init(copyFrom: self, cacheResults: false).all()
        let ids = results.map { String($0.id!) }
        CacheStore.shared().write(cacheKey, value: ",".join(ids))
        return results
      }
      else {
        let ids = split(idString!) { $0 == "," }.map { ($0 as NSString).integerValue ?? 0 }
        let results = self.dynamicType.init().filter("id IN (\(idString!))").all()
        return results.sorted {
          (record1, record2) -> Bool in
          let index1 = Swift.find(ids, record1.id!)
          let index2 = Swift.find(ids, record2.id!)
          return index1 != nil && index2 != nil && index1! < index2!
        }
      }
    }
    let results = DatabaseConnection.sharedConnection().executeQuery(query, stringParameters: parameters)
    let type = RecordType.self
    return removeNils(results.map { $0.error == nil ? type(databaseRow: $0.data) : nil })
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
    This method runs the query, getting the last result based on the current
    ordering.

    This will only pull a single row from the database.

    :returns:   The fetched result.
    */
  public func last() -> RecordType? {
    return self.reverse().first()
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
    let count = results.isEmpty ? 0 : results[0].data["tailor_record_count"]!.intValue!
    return count
  }
  
  /**
    This method determines if the result set for this query is empty.

    :returns: Whether there are no results.
    */
  public func isEmpty() -> Bool {
    return self.count() == 0
  }
}