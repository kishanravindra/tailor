import Foundation

/**
  This class provides a base class for models backed by the database.
  */
class Record {
  /** The unique identifier for the record. */
  var id : Int!
  
  /**
    This method initializes a record with no data.
    */
  convenience init() {
    self.init(data: [:])
  }

  /**
    This method initializes a record with information from the database.

    :param: data  The columns from the database.
    */
  required init(data: [String:Any]) {
    self.id = data["id"] as? Int
  }

  //MARK: - Structure
  
  /**
    The name of the table that backs this class.

    This implementation returns an empty string, but subclasses must override it
    to provide a real value;

    :returns: The table name.
    */
  class func tableName() -> String {
    return ""
  }

  //MARK: - Fetching
  
  /**
    This method executes a query against the database and builds records out of
    it.

    The records will be of whatever type this method is called on.

    :param: query       The query to execute
    :param: parameters  The information to interpolate into the query.
    :returns:           The created records.
    */
  class func query(query: String, parameters: [String]) -> [Record] {
    let rows = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
    return rows.map { self.init(data: $0.data) }
  }
  
  /**
    This method searches for records matching a set of conditions.

    The resulting records will be of whatever type this method is called on.

    :param: conditions    The constraints on the returned records.
    :param: order         The order in which the results should be returned.
    :param: limit         The maximum number of results to return.
    :returns:             The created records.
    */
  class func find(conditions: [String:String] = [:], order: [String: NSComparisonResult] = [:], limit: Int? = nil) -> [Record] {
    var query = "SELECT * FROM \(self.tableName())"
    var parameters : [String] = []
    
    let keyRegex = NSRegularExpression(pattern: "[^A-Za-z_0-9]", options: nil, error: nil)
    
    if !conditions.isEmpty {
      query += " WHERE"
      
      var first = true
      for (column,value) in conditions {
        if first {
          first = false
        }
        else {
          query += " AND"
        }
        
        let range = NSMakeRange(0, countElements(column))
        var sanitizedColumn = keyRegex.stringByReplacingMatchesInString(column, options: nil, range: range, withTemplate: "")
        query += " \(column)=?"
        
        parameters.append(value)
      }
    }
    
    if !order.isEmpty {
      query += " ORDER BY "
      
      var first = true
      for (column,direction) in order {
        let sqlDirection = (direction == NSComparisonResult.OrderedAscending ? "ASC" : "DESC")
        let range = NSMakeRange(0, countElements(column))
        var sanitizedColumn = keyRegex.stringByReplacingMatchesInString(column, options: nil, range: range, withTemplate: "")
        query += "\(sanitizedColumn) \(sqlDirection)"
        parameters.append(column)
      }
    }
    
    if limit != nil {
      query += " LIMIT \(limit!)"
    }
    return self.query(query, parameters: parameters)
  }
  
  /**
    This method pulls up a single record from the database.

    :param: id  The id of the record to find.
    :returns:   The record, if it was found.
    */
  class func find(id: Int) -> Record? {
    let results = self.find(conditions: ["id": "\(id)"])
    return results.isEmpty ? nil : results[0]
  }
  
}