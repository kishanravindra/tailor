/**
  This type provides a paginated list of records from a query.

  TODO: better support for nonsensical pages and page size
  */
public struct PaginatedList<RecordType: Persistable>: Equatable {
  /** The query that returns the full list of records. */
  public let query: Query<RecordType>
  
  /** The page in the list that we are showing. */
  public let page: Int
  
  /** How many records are on each page. */
  public let pageSize: Int
  
  /**
    This initializer creates a paginated list.
    
    - parameter query:      The query that returns the full list of records.
    - parameter page:       The page that we are on.
    - parameter pageSize:   How many records are on each page.
    */
  public init(query: Query<RecordType>, page: Int = 1, pageSize: Int = 10) {
    self.query = query
    self.page = page
    self.pageSize = pageSize
  }
  
  /**
    This method fetches the full list of records.
    */
  public func all() -> [RecordType] {
    var (queryText,parameters) = query.toSql()
    let startIndex = pageSize * (page - 1)
    queryText += " LIMIT \(startIndex),\(pageSize)"
    let results = Application.sharedDatabaseConnection().executeQuery(queryText, parameters: parameters)
    return results.flatMap {
      (row: DatabaseRow)->RecordType? in
      do {
        return try RecordType(databaseRow: row)
      }
      catch {
        return nil
      }
    }
  }
  
  /**
    This method gets the number of pages in the list.
    */
  public var numberOfPages: Int {
    let count = query.count()
    if count == 0 { return 1 }
    return (count / pageSize) + (count % pageSize == 0 ? 0 : 1)
  }
}

/**
  This function determines if two lists are equal.

  The lists will be equal if they have the same query, page, and page size.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two lists are equal.
  */
public func ==<RecordType>(lhs: PaginatedList<RecordType>, rhs: PaginatedList<RecordType>) -> Bool {
  return lhs.query == rhs.query && lhs.page == rhs.page && lhs.pageSize == rhs.pageSize
}