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
  
    It will set the id, and set any other dynamic properties it can.

    :param: data  The columns from the database.
    */
  required init(data: [String:Any]) {
    self.id = data["id"] as? Int
    
    let klass : AnyClass = object_getClass(self)
    for (propertyName, columnName) in self.dynamicType.persistedPropertyMapping() {
      if let value = data[columnName] {
        let capitalName = String(propertyName[propertyName.startIndex]).capitalizedString +
          propertyName.substringFromIndex(advance(propertyName.startIndex, 1))
        let setterName = "set" + capitalName + ":"
        
        let setter = class_getInstanceMethod(klass, Selector(setterName))
        if setter != nil {
          var objectValue : AnyObject = ""
          
          switch value {
          case let string as String:
            objectValue = string
          case let date as NSDate:
            objectValue = date
          case let int as Int:
            objectValue = NSNumber(integer: int)
          case let double as Double:
            objectValue = NSNumber(double: double)
          default:
            break
          }
          tailorInvokeSetter(self, setter, objectValue)
        }
      }
    }
  }

  //MARK: - Structure
  
  /**
    This method provides name of the table that backs this class.

    This implementation returns an empty string, but subclasses must override it
    to provide a real value;

    :returns: The table name.
    */
  class func tableName() -> String { return "" }
  
  /**
    This method provides the names of the properties in this class that are
    persisted to its table.
    
    The properties should be the Swift properties. They will be automatically
    camel-cased to get the database names.
  
    This implementation returns an empty list, but subclasses can override it
    to opt in to automatic extraction and persistence of properties.
  
    :see: persistedPropertyMapping
  
    :returns: The property names
    */
  class func persistedProperties() -> [String] { return [] }
  
  /**
    This method provides a mapping between the names of properties in instances
    of this class and the names of columns in the database.

    Any properties that are provided in this list will be automatically set
    by the initializer when creating a record from a database row. They will
    also be automatically included in the persisted data when creating or
    updating a record. They must be dynamic properties for this to work.

    The default implementation takes the property names returned by
    persistedProperties and creates column names by underscorizing them.

    :returns: The property mapping.
    */
  class func persistedPropertyMapping() -> [String:String] {
    var dictionary = [String:String]()
    for property in self.persistedProperties() {
      dictionary[property] = property.underscored()
    }
    return dictionary
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
  class func query<RecordType : Record>(query: String, parameters: [String]) -> [RecordType] {
    let rows = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
    return rows.map { RecordType.init(data: $0.data) }
  }
  
  /**
    This method searches for records matching a set of conditions.

    The resulting records will be of whatever type this method is called on.

    :param: conditions    The constraints on the returned records.
    :param: order         The order in which the results should be returned.
    :param: limit         The maximum number of results to return.
    :returns:             The created records.
    */
  class func find<RecordType : Record>(conditions: [String:String] = [:], order: [String: NSComparisonResult] = [:], limit: Int? = nil) -> [RecordType] {
    var query = "SELECT * FROM \(self.tableName())"
    var parameters : [String] = []
    
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
        
        query += " \(DatabaseConnection.sanitizeColumnName(column))=?"
        
        parameters.append(value)
      }
    }
    
    if !order.isEmpty {
      query += " ORDER BY "
      
      var first = true
      for (column,direction) in order {
        let sqlDirection = (direction == NSComparisonResult.OrderedAscending ? "ASC" : "DESC")
        let range = NSMakeRange(0, countElements(column))
        query += "\(DatabaseConnection.sanitizeColumnName(column)) \(sqlDirection)"
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
  class func find<RecordType: Record>(id: Int) -> RecordType? {
    let results : [RecordType] = self.find(conditions: ["id": "\(id)"])
    return results.isEmpty ? nil : results[0]
  }
  
  //MARK: - Persisting
  
  /**
    This method gets the values to save to the database when this record is
    saved.

    This implementation takes the persisted property mapping, looks up the
    current values for those properties, and converts them into strings.
  
    :returns:   The values to save.
    */
  func valuesToPersist() -> [String:String] {
    var values = [String:String]()
    
    let klass: AnyClass! = object_getClass(self)
    for (propertyName, columnName) in self.dynamicType.persistedPropertyMapping() {
      let getter = class_getInstanceMethod(klass, Selector(propertyName))
      if getter != nil {
        var value: AnyObject?
        var stringValue : String?
        
        switch propertyName {
        case "updatedAt":
          value = NSDate()
        default:
          value = tailorInvokeGetter(self, getter)
        }
        switch value {
        case let string as String:
          stringValue = string
        case let date as NSDate:
          stringValue = date.descriptionWithCalendarFormat(nil, timeZone: DatabaseConnection.sharedConnection().timeZone, locale: nil)
        case let number as NSNumber:
          stringValue = number.stringValue
        default:
          break
        }
        
        if stringValue != nil {
          values[columnName] = stringValue
        }
      }
    }
    return values
  }
  
  /**
    This method saves the record to the database.
    */
  func save() {
    if self.id != nil {
      self.saveUpdate()
    }
    else {
      self.saveInsert()
    }
  }
  
  /**
    This method saves the record to the database by inserting it.
    */
  func saveInsert() {
    var query = "INSERT INTO \(self.dynamicType.tableName()) ("
    var parameters = [String]()
    
    var firstParameter = true
    var parameterString = ""
    let values = self.valuesToPersist()
    for (propertyName, columnName) in self.dynamicType.persistedPropertyMapping() {
      let value = values[columnName]
      if value == nil {
        continue
      }
      if firstParameter {
        firstParameter = false
      }
      else {
        query += ", "
        parameterString += ", "
      }
      query += "\(DatabaseConnection.sanitizeColumnName(columnName))"
      parameterString += "?"
      parameters.append(value!)
    }
    query += ") VALUES (\(parameterString))"
    let result = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)[0]
    self.id = result.data["id"] as Int
  }
  
  /**
    This method saves the record to the database by updating it.
    */
  func saveUpdate() {
    var query = "UPDATE \(self.dynamicType.tableName())"
    var parameters = [String]()
    
    var firstParameter = true
    let values = self.valuesToPersist()
    for (propertyName, columnName) in self.dynamicType.persistedPropertyMapping() {
      let value = values[columnName]
      if firstParameter {
        query += " SET "
        firstParameter = false
      }
      else {
        query += ", "
      }
      query += "\(DatabaseConnection.sanitizeColumnName(columnName)) = "
      if value == nil {
        query += "NULL"
      }
      else {
        query += "?"
        parameters.append(value!)
      }
    }
    query += " WHERE id = ?"
    parameters.append(String(self.id))
    DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
  }
  
  /**
    This method deletes the record from the database.
    */
  func destroy() {
    let query = "DELETE FROM \(self.dynamicType.tableName()) WHERE id = ?"
    DatabaseConnection.sharedConnection().executeQuery(query, String(self.id))
  }
}