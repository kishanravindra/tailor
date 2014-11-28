import Foundation

/**
  This class provides a base class for models backed by the database.
  */
public class Record : Model {
  /** The unique identifier for the record. */
  public var id : NSNumber!
  
  /**
    This method initializes a record with no data.
    */
  public convenience override init() {
    self.init(data: [:])
  }

  /**
    This method initializes a record with map of the attributes.
  
    It will set the id, and set any other dynamic properties it can.

    :param: data          The fields to set.
    :param: fromDatabase  Whether the keys in the hash use the database
                          column names rather than the attribute names on the
                          record.
    */
  public required init(data: [String:Any], fromDatabase: Bool = false) {
    if let id = data["id"] as? Int {
      self.id = NSNumber(integer: id)
    }
    super.init()
    
    let klass : AnyClass = object_getClass(self)
    for (propertyName, columnName) in self.dynamicType.persistedPropertyMapping() {
      let key = fromDatabase ? columnName : propertyName
      if let value = data[key] {
        self.setValue(value, forKey: propertyName)
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
  public class func tableName() -> String {
    return self.modelName().pluralized
  }
  
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
  public class func persistedProperties() -> [String] { return [] }
  
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
  public class func persistedPropertyMapping() -> [String:String] {
    var dictionary = [String:String]()
    for property in self.persistedProperties() {
      dictionary[property] = property.underscored()
    }
    return dictionary
  }

  /**
    This method fetches a relationship from this record to one other record.

    This will look for a field on this record that contains the id of the other
    record.

    :param: foreignKey    The attribute on this record that contains the id. If
                          this is not provided, it will be the name of the other
                          model, with the first letter lowercased, followed by
                          "Id".
    :returns:             The fetched record.
    */
  public func toOne<OtherRecordType : Record>(foreignKey inputForeignKey: String? = nil) -> OtherRecordType? {
    let foreignKey = inputForeignKey ?? (OtherRecordType.modelName().lowercaseInitial + "Id")
    return Query<OtherRecordType>().filter(["id": self.valueForKey(foreignKey)]).first()
  }
  
  /**
    This method fetches a relationship from this record to many related records.
  
    This will look for a field on the other record that contains the id of this
    record.
  
    :param: foreignKey    The attribute on the other record that contains the
      id. If this is not provided, it will be the name of this model, with the
      first letter lowercased, followed by "Id".
    :returns:             The fetched records.
  */
  public func toMany<OtherRecordType : Record>(foreignKey inputForeignKey: String? = nil) -> Query<OtherRecordType> {
    let foreignKey = inputForeignKey ?? (self.dynamicType.modelName().lowercaseInitial + "Id")
    return Query<OtherRecordType>().filter([foreignKey: self.id])
  }
  
  //MARK: - Creating
  
  /**
    This method takes a value of an arbitrary type and serializes it so it can
    be put into a query.

    :param: value     The value to serialize.
    :param: key       The key that the value is for. This implementation does
                      nothing with it, but subclasses can use this to provide
                      custom serialization for vertain keys.
    :returns:         The value serialized as both a string and an NSData
                      object, so it can be used in either type of query.
    */
  public class func serializeValueForQuery(value: AnyObject?, key: String) -> (String?, NSData?) {
    var stringValue: String? = nil
    var dataValue: NSData? = nil
    switch value {
    case let string as String:
      stringValue = string
    case let date as NSDate:
      let timeZone = DatabaseConnection.sharedConnection().timeZone
      stringValue = date.format("db", timeZone: timeZone)
    case let number as NSNumber:
      stringValue = number.stringValue
    case let data as NSData:
      dataValue = data
    default:
      break
    }
    
    if dataValue == nil && stringValue != nil {
      dataValue = stringValue!.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    return (stringValue, dataValue)
  }
  
  
  /**
    This method creates a record with given attributes and tries to save it.
  
    After the block runs, the record will be saved and returned. The caller can
    check whether the save was successful by checking whether the returned
    record's id is non-null.
  
    :param: data    The fields to set on the record.
    :returns:       The record
    */
  public class func create(data: [String: Any]) -> Self {
    let record = self.init(data: data)
    record.save()
    return record
  }
  
  //MARK: - Persisting
  
  /**
    This method gets the values to save to the database when this record is
    saved.

    This implementation takes the persisted property mapping, looks up the
    current values for those properties, and converts them into the appropriate
    data structure.
  
    :returns:   The values to save.
    */
  public func valuesToPersist() -> [String:NSData] {
    var values = [String:NSData]()
    
    let klass: AnyClass! = object_getClass(self)
    for (propertyName, columnName) in self.dynamicType.persistedPropertyMapping() {
      let value : AnyObject? = self.valueForKey(propertyName)
      let (stringValue, dataValue) = self.dynamicType.serializeValueForQuery(value, key: propertyName)
      
      if dataValue != nil {
        values[propertyName] = dataValue!
      }
    }
    return values
  }
  
  /**
    This method saves the record to the database.
  
    It will also set values for the createdAt and updatedAt fields, if they
    are defined.
  
    :returns: Whether we were able to save the record.
    */
  public func save() -> Bool {
    if !self.validate() {
      return false
    }
    
    let propertyMapping = self.dynamicType.persistedPropertyMapping()
    
    if propertyMapping["createdAt"] != nil {
      if self.valueForKey("createdAt") == nil {
        self.setValue(NSDate(), forKey: "createdAt")
      }
    }
    if propertyMapping["updatedAt"] != nil {
      self.setValue(NSDate(), forKey: "updatedAt")
    }
    
    if self.id != nil {
      return self.saveUpdate()
    }
    else {
      return self.saveInsert()
    }
  }
  
  /**
    This method saves the record to the database by inserting it.
  
    :returns:   Whether we were able to save the record.
    */
  private func saveInsert() -> Bool {
    var query = "INSERT INTO \(self.dynamicType.tableName()) ("
    var parameters = [NSData]()
    
    var firstParameter = true
    var parameterString = ""
    let values = self.valuesToPersist()
    for (propertyName, columnName) in self.dynamicType.persistedPropertyMapping() {
      let value = values[propertyName]
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
      query += "\(columnName)"
      parameterString += "?"
      parameters.append(value!)
    }
    query += ") VALUES (\(parameterString))"
    let result = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)[0]
    
    if let error = result.error {
      self.errors.add("_database", error)
      return false
    }
    else {
      self.id = result.data["id"] as Int
      return true
    }
  }
  
  /**
    This method saves the record to the database by updating it.
  
    :returns:   Whether we were able to save the record.
    */
  private func saveUpdate() -> Bool {
    var query = "UPDATE \(self.dynamicType.tableName())"
    var parameters = [NSData]()
    
    var firstParameter = true
    let values = self.valuesToPersist()
    for (propertyName, columnName) in self.dynamicType.persistedPropertyMapping() {
      let value = values[propertyName]
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
    parameters.append(self.id.stringValue.dataUsingEncoding(NSUTF8StringEncoding)!)
    let result = DatabaseConnection.sharedConnection().executeQuery(query, parameters: parameters)
    
    if result.count > 0 {
      if let error = result[0].error {
        self.errors.add("_database", error)
        return false
      }
    }
    return true
  }
  
  /**
    This method deletes the record from the database.
    */
  public func destroy() {
    let query = "DELETE FROM \(self.dynamicType.tableName()) WHERE id = ?"
    DatabaseConnection.sharedConnection().executeQuery(query, self.id.stringValue)
  }
}