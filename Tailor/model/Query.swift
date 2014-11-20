import Foundation

/**
  This class represents a query to fetch records.

  It provides methods for building the query by method chaining.
  */
public class Query<RecordType: Record> {
  //MARK: - Structure
  
  /** A portion of a SQL query that contains a query and the bind parameters. */
  public typealias SqlFragment = (query: String, parameters: [String])
  
  /** The part of the query for filtering the result set. */
  public let whereClause: SqlFragment
  
  /** The part of the query for defining the order of the returned results. */
  public let orderClause: SqlFragment
  
  /** The part of the query for defining how many results should be returned. */
  public let limitClause: SqlFragment
  
  /**
    This method builds a query from its component clause.

    :param: whereClause     The portion of the query for filtering the result
                            set.
    :param: orderClause     The portion of the query specifying the order of the
                            returned results.
    :param: limitClause     The portion of the query specifying how many results
                            should be returned.
    */
  public required init(whereClause: SqlFragment = ("", []), orderClause: SqlFragment = ("", []), limitClause: SqlFragment = ("", [])) {
    self.whereClause = whereClause
    self.orderClause = orderClause
    self.limitClause = limitClause
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
    if !clause.query.isEmpty {
      clause.query += " AND "
    }
    clause.query += query
    clause.parameters.extend(parameters)
    return self.dynamicType.init(whereClause: clause, orderClause: orderClause, limitClause: limitClause)
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
    let properties = RecordType.persistedPropertyMapping()
    var parameters : [String] = []
    if !conditions.isEmpty {
      for (fieldName,value) in conditions {
        var columnName = properties[fieldName]
        if fieldName == "id" {
          columnName = fieldName
        }
        if columnName != nil  {
          if !query.isEmpty {
            query += " AND"
          }
          
          if value != nil {
            let (stringValue, _) = RecordType.serializeValueForQuery(value, key: fieldName)
            if stringValue != nil {
              query += " \(columnName!)=?"
              parameters.append(stringValue!)
            }
          }
          else {
            query += " \(columnName!) IS NULL"
          }
        }
        else {
          NSLog("Error: Could not map %@.%@ to column", RecordType.modelName(), fieldName)
        }
      }
    }
    return self.filter(query, parameters)
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
    let properties = RecordType.persistedPropertyMapping()
    var columnName = properties[fieldName]
    var clause = orderClause
    if columnName != nil {
      if !clause.query.isEmpty {
        clause.query += ","
      }
      let orderDescription = order == .OrderedAscending ? "ASC" : "DESC"
      clause.query += " \(columnName!) \(orderDescription)"
    }
    else {
      NSLog("Error: Could not map %@.%@ to column", RecordType.modelName(), fieldName)
    }
    return self.dynamicType.init(whereClause: whereClause, orderClause: clause, limitClause: limitClause)
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
    return self.dynamicType.init(whereClause: whereClause, orderClause: orderClause, limitClause: clause)
  }
  
  //MARK: - Running Query
  
  /**
    This method gets the full SQL for running this query.

    :returns: The SQL query and bind parameters.
    */
  public func toSql() -> SqlFragment {
    var query = "SELECT * FROM \(RecordType.tableName())"
    var parameters : [String] = []
    let clauses = [
      ("WHERE", whereClause),
      ("ORDER BY", orderClause),
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
}