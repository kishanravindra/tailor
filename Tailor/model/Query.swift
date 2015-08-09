import Foundation


/** A portion of a SQL query that contains a query and the bind parameters. */
public typealias SqlFragment = (query: String, parameters: [DatabaseValue])

/**
  This protocol describes a query that can be run for fetching records.

  This functionality is in a protocol because it is implemented by two different
  types. The `Query` type is statically parameterized with the type of record it
  fetches, and provides the best solution when the record type is known at
  compile time. The `GenericQuery` type requires that the record type be
  provided in an initialization parameter, and is better suited for running
  queries against dynamically defined record types.

  Creating other types that conform to this protocol is not supported. The
  requirements for this protocol may change in future releases with no warning.
  */
public protocol QueryType {
  //MARK: - Structure
  
  /** The fields that the query will select. */
  var selectClause: String { get }
  
  /** The part of the query for filtering the result set. */
  var whereClause: SqlFragment { get }
  
  /** The part of the query for defining the order of the returned results. */
  var orderClause: SqlFragment { get }
  
  /** The part of the query for defining how many results should be returned. */
  var limitClause: SqlFragment { get }
  
  /** The part of the query for joining to other tables. */
  var joinClause: SqlFragment { get }
  
  /** Whether the query should cache its results. */
  var cacheResults: Bool { get }
  
  /**
    The type of record that we are fetching.
    */
  var recordType: Persistable.Type { get }
  
  /** The table that we are from fetching. */
  var tableName: String { get }
  
  /**
    This initializer creates a query with all its component parts.

    - parameter selectClause:     The fields that will be selected.
    - parameter whereClause:      The portion of the query for filtering the
                                  result set.
    - parameter orderClause:      The portion of the query specifying the order
                                  of the returned results.
    - parameter limitClause:      The portion of the query specifying how many
                                  results should be returned.
    - parameter joinClause:       The portion of the query specifying other
                                  tables to join to.
    - parameter cacheResults:     Whether the query should cache its results.
    - parameter recordType:       The type of record that the query should
                                  fetch. This has to be nullable to support the
                                  way that the `Query` type dynamically
                                  specifies is record type.
    - parameter tableName:        The name of the table this fetches records
                                  from.
    */
  init(selectClause: String, whereClause: SqlFragment, orderClause: SqlFragment, limitClause: SqlFragment, joinClause: SqlFragment, cacheResults: Bool, recordType: Persistable.Type?, tableName: String)
}

extension QueryType {
  /**
    This method builds a query from its component clause.
  
    - parameter copyFrom:         The query that we should use as a baseline for
                                  the new query.
    - parameter selectClause:     The fields that will be selected.
    - parameter whereClause:      The portion of the query for filtering the
                                  result set.
    - parameter orderClause:      The portion of the query specifying the order
                                  of the returned results.
    - parameter limitClause:      The portion of the query specifying how many
                                  results should be returned.
    - parameter joinClause:       The portion of the query specifying other
                                  tables to join to.
    - parameter cacheResults:     Whether the query should cache its results.
    - parameter recordType:       The type of record that the query should
                                  fetch. This has to be nullable to support the
                                  way that the `Query` type dynamically
                                  specifies is record type.
    - parameter tableName:        The name of the table this fetches records
                                  from.
  */
  public init(copyFrom: QueryType? = nil, selectClause: String? = nil, whereClause: SqlFragment? = nil, orderClause: SqlFragment? = nil, limitClause: SqlFragment? = nil, joinClause: SqlFragment? = nil, cacheResults: Bool? = nil, recordType: Persistable.Type? = nil, tableName: String? = nil) {
    
    self.init(
      selectClause: selectClause ?? copyFrom?.selectClause ?? "*",
      whereClause: whereClause ?? copyFrom?.whereClause ?? ("", []),
      orderClause: orderClause ?? copyFrom?.orderClause ?? ("", []),
      limitClause: limitClause ?? copyFrom?.limitClause ?? ("", []),
      joinClause: joinClause ?? copyFrom?.joinClause ?? ("", []),
      cacheResults: cacheResults ?? copyFrom?.cacheResults ?? false,
      recordType: recordType ?? copyFrom?.recordType,
      tableName: tableName ?? copyFrom?.tableName ?? ""
    )
  }
  
  //MARK: - Query Building
  
  /**
    This method adds a filter clause based on raw SQL, and returns a new version
    of the query with the filter added.
  
    - parameter query:          The new clause for the query
    - parameter parameters:     The new bind parameters
    - returns:                  The new query object.
    */
  public func filter(query: String, _ parameters: [DatabaseValueConvertible] = []) -> Self {
    var clause = whereClause
    
    if query.isEmpty {
      return self
    }
    
    if !clause.query.isEmpty {
      clause.query += " AND "
    }
    clause.query += query
    clause.parameters.extend(parameters.map { $0.databaseValue })
    return self.dynamicType.init(
      copyFrom: self,
      whereClause: clause
    )
  }
  
  /**
    This method adds a filter clause based on a dictionary of conditions, and
    returns a new version of the query with the filter added.
    
    - parameter conditions:     The conditions, with keys matching field names
                                on the record type and values matching the field
                                types on the record type.
    - returns:                  The new query object.
    */
  public func filter(conditions: [String: DatabaseValueConvertible?]) -> Self {
    var query = ""
    var parameters : [DatabaseValue] = []
    if !conditions.isEmpty {
      for (columnName,value) in conditions {
        if !query.isEmpty {
          query += " AND "
        }
        
        if let value = value {
          query += "\(tableName).\(columnName)=?"
          parameters.append(value.databaseValue)
        }
        else {
          query += "\(tableName).\(columnName) IS NULL"
        }
      }
    }
    return self.dynamicType.init(copyFrom: self.filter(query, parameters.map { $0 as DatabaseValueConvertible }))
  }
  
  
  /**
    This method attaches an ordering to the query, and returns the result.
    
    - parameter fieldName:    The name of the field to order by, using the field
                              name from the record type.
    - parameter order:        Whether to put the results in ascending or
                              descending order.
    - returns:                The new query.
  */
  public func order(columnName: String, _ order: NSComparisonResult) -> Self {
    var clause = orderClause
    if !clause.query.isEmpty {
      clause.query += ", "
    }
    let orderDescription = order == .OrderedAscending ? "ASC" : "DESC"
    clause.query += "\(tableName).\(columnName) \(orderDescription)"
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
    
    - parameter limit:      The limit to apply.
    - returns:              The new query.
    */
  public func limit(limit: Int) -> Self {
    var newLimit = limit
    if let oldLimit = Int(self.limitClause.query) {
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
    
    - parameter selectClause:     The SQL for selecting the fields, not
                                  including the SELECT keyword.
    - returns:                    The new query.
    */
  public func select(selectClause: String) -> Self {
    return self.dynamicType.init(
      copyFrom: self,
      selectClause: selectClause
    )
  }
  
  /**
  This method adds a join to the query.
  
  - parameter query:          The SQL for selecting the fields, including the
                              JOIN keywords.
  - parameter parameters:     The bind parameters to pass to the join
                              statement.
  - returns:                  The new query.
  */
  public func join(query: String, _ parameters: [DatabaseValueConvertible] = []) -> Self {
    var clause = self.joinClause
    
    if !clause.query.isEmpty {
      clause.query += " "
    }
    clause.query += query
    clause.parameters.extend(parameters.map { $0.databaseValue })
    return self.dynamicType.init(
      copyFrom: self,
      joinClause: clause
    )
  }
  
  /**
    This method adds a join to the query.
    
    - parameter recordType:   The target record type for the join.
    - parameter fromColumn:   The field on the target record to match for the
                              join.
    - parameter toColumn:     The field on this record to match for the join.
    - returns:                The new query.
    */
  public func join<OtherRecordType: Persistable>(recordType: OtherRecordType.Type, fromColumn: String, toColumn: String) -> Self {
    let fromTable = recordType.tableName
    let toTable = tableName
    return self.join("INNER JOIN \(fromTable) ON \(fromTable).\(fromColumn) = \(toTable).\(toColumn)")
  }
  
  
  /**
    This method reverses the order of a query.
    
    If the query has no order clause, it will order the query in descending
    order by id.
    
    - returns:   The new query.
    */
  public func reverse() -> Self {
    var orderClause = self.orderClause
    if orderClause.query.isEmpty {
      orderClause.query = "id DESC"
    }
    else {
      var components = orderClause.query.componentsSeparatedByString(",")
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
    
    - returns:   The query with caching turned on.
    */
  public func cached() -> Self {
    return self.dynamicType.init(copyFrom: self, cacheResults: true)
  }
  
  
  //MARK: - Running Query
  
  /**
    This method gets the full SQL for running this query.
    
    - returns: The SQL query and bind parameters.
    */
  public func toSql() -> SqlFragment {
    var query = "SELECT \(selectClause) FROM \(tableName)"
    var parameters : [DatabaseValue] = []
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
    
    - returns:   The fetched records.
    */
  public func allRecords() -> [Persistable] {
    let (query, parameters) = self.toSql()
    if self.cacheResults {
      let parameterString = ",".join(parameters.map { String($0) })
      let cacheKey = query + "(" + parameterString + ")"
      
      var cachedIds = Application.cache.read(cacheKey)
      if !(cachedIds?.matches("[0-9,]*") ?? false) {
        cachedIds = nil
      }
      
      guard let idString = cachedIds else {
        let results = self.dynamicType.init(copyFrom: self, cacheResults: false).allRecords()
        let ids = results.flatMap { $0.id }.map { String($0) }
        Application.cache.write(cacheKey, value: ",".join(ids), expireIn: nil)
        return results
      }
      let ids = idString.componentsSeparatedByString(",").map { Int($0) ?? 0 } ?? []
      let results = self.dynamicType.init().filter("id IN (\(idString))").allRecords()
      return results.sort {
        (record1, record2) -> Bool in
        guard let id1 = record1.id, id2 = record2.id else { return false }
        guard let index1 = ids.indexOf(id1), let index2 = ids.indexOf(id2) else { return false }
        return index1 < index2
      }
    }
    let results = Application.sharedDatabaseConnection().executeQuery(query, parameters: parameters)
    return results.flatMap {
      if $0.error == nil {
        return recordType.build($0)
      }
      return nil
    }
  }
  
  /**
    This method gets a count of the records matching the filters in this query.
    
    - returns:   The count.
    */
  public func count() -> Int {
    let (query, parameters) = self.select("count(*) as tailor_record_count").toSql()
    let results = Application.sharedDatabaseConnection().executeQuery(query, parameters: parameters)
    let count = results.isEmpty ? 0 : results[0].data["tailor_record_count"]?.intValue ?? 0
    return count
  }
  
  /**
    This method determines if the result set for this query is empty.
    
    - returns: Whether there are no results.
    */
  public func isEmpty() -> Bool {
    return self.count() == 0
  }
}

/**
  This type provides a query that can be built with a dynamically specified type.
  */
public struct GenericQuery: QueryType {
  /** The fields that the query will select. */
  public let selectClause: String
  
  /** The part of the query for filtering the result set. */
  public let whereClause: SqlFragment
  
  /** The part of the query for defining the order of the returned results . */
  public let orderClause: SqlFragment
  
  /** The part of the query for defining how many results should be returned. */
  public let limitClause: SqlFragment
  
  /** The part of the query for joining to other tables. */
  public let joinClause: SqlFragment
  
  /** Whether the query should cache its results. */
  public let cacheResults: Bool
  
  /** The type of record that we are fetching. */
  public let recordType: Persistable.Type
  
  /** The table that we are from fetching. */
  public let tableName: String
  
  /**
    This initializer creates a query with all its component parts.
    
    - parameter selectClause:     The fields that will be selected.
    - parameter whereClause:      The portion of the query for filtering the
                                  result set.
    - parameter orderClause:      The portion of the query specifying the order
                                  of the returned results.
    - parameter limitClause:      The portion of the query specifying how many
                                  results should be returned.
    - parameter joinClause:       The portion of the query specifying other
                                  tables to join to.
    - parameter cacheResults:     Whether the query should cache its results.
    - parameter recordType:       The type of record that the query should
                                  fetch. This has to be nullable to support the
                                  protocol, but you *must* provide a real value,
                                  or this will raise a fatal error.
    - parameter tableName:        The name of the table this fetches records
                                  from.
    */
  public init(selectClause: String, whereClause: SqlFragment, orderClause: SqlFragment, limitClause: SqlFragment, joinClause: SqlFragment, cacheResults: Bool, recordType: Persistable.Type?, tableName: String) {
    guard let recordType = recordType else {
      fatalError("Tried to initialize a GenericQuery with no recordType")
    }
    self.selectClause = selectClause
    self.whereClause = whereClause
    self.orderClause = orderClause
    self.limitClause = limitClause
    self.joinClause = joinClause
    self.cacheResults = cacheResults
    self.recordType = recordType
    self.tableName = tableName
    
  }
}
/**
  This type provides a query for fetching records with a statically defined
  type. It also provides convenience methods for fetching records with the
  provided type.
  */
public struct Query<RecordType: Persistable>: QueryType {
  //MARK: - Structure
  
  /** A portion of a SQL query that contains a query and the bind parameters. */
  public typealias SqlFragment = (query: String, parameters: [DatabaseValue])
  
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
    The type of record that this query should fetch.

    This is always the `RecordType` generic parameter.
    */
  public var recordType: Persistable.Type { return RecordType.self }
  
  /**
    The name of the table that this query fetches records from.

    This is always taken from the `RecordType` generic parameter.
    */
  public var tableName: String { return RecordType.tableName }
  
  /** Whether the query should cache its results. */
  public let cacheResults: Bool
  
    /**
    This initializer creates a query with all its component parts.
    
    - parameter selectClause:     The fields that will be selected.
    - parameter whereClause:      The portion of the query for filtering the
                                  result set.
    - parameter orderClause:      The portion of the query specifying the order
                                  of the returned results.
    - parameter limitClause:      The portion of the query specifying how many
                                  results should be returned.
    - parameter joinClause:       The portion of the query specifying other
                                  tables to join to.
    - parameter cacheResults:     Whether the query should cache its results.
    - parameter recordType:       The type of record that the query should
                                  fetch. This is ignored, because the record
                                  type is always taken from the generic
                                  parameter.
    - parameter tableName:        The name of the table this fetches records
                                  from. This is ignored, because the table name
                                  is always taken from the generic parameter.
    */
  public init(selectClause: String, whereClause: SqlFragment, orderClause: SqlFragment, limitClause: SqlFragment, joinClause: SqlFragment, cacheResults: Bool, recordType: Persistable.Type?, tableName: String) {
    self.selectClause = selectClause
    self.whereClause = whereClause
    self.orderClause = orderClause
    self.limitClause = limitClause
    self.joinClause = joinClause
    self.cacheResults = cacheResults
  }
  
  //MARK: - Running Query
    
  /**
    This method runs the query and creates records from the result set.

    - returns:   The fetched records.
    */
  public func all() -> [RecordType] {
    return self.allRecords().flatMap { $0 as? RecordType }
  }
  
  /**
    This method runs the query, limiting it to 1 result, and returns that
    result.

    - returns:   The fetched record.
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

    - returns:   The fetched result.
    */
  public func last() -> RecordType? {
    return self.reverse().first()
  }
 
  /**
    This method finds a record with an id.

    - returns:   The fetched record.
    */
  public func find(id: Int) -> RecordType? {
    return self.filter(["id": id]).first()
  }
}