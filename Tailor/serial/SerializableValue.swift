/**
  This enum represents a simple value that can be natively serialized into
  multiple formats.
  */
public enum SerializableValue: Equatable {
  /** A  String. */
  case String(Swift.String)
  
  /** An Array, containing other serializable values. */
  case Array([SerializableValue])
  
  /** A dictionary, mapping Swift strings to other serializable values. */
  case Dictionary([Swift.String: SerializableValue])
  
  /** A null value. */
  case Null
  
  /** A boolean flag. */
  case Boolean(Bool)
  
  /** A data blob. */
  case Data(NSData)
  
  /** Any integer type. */
  case Integer(Int)
  
  /** Any floating-point type. */
  case Double(Swift.Double)
  
  /** A full timestamp type */
  case Timestamp(Tailor.Timestamp)
  
  /** A standalone date. */
  case Date(Tailor.Date)
  
  /** A standalone time. */
  case Time(Tailor.Time)
  
  //MARK: - Converting to Other Values
  
  /**
    This method gets the type that this case wraps around.
    */
  public var wrappedType: Any.Type {
    switch(self) {
    case .String: return Swift.String.self
    case .Array: return [SerializableValue].self
    case .Dictionary: return Swift.Dictionary<Swift.String,SerializableValue>.self
    case .Null: return NSNull.self
    case .Integer: return Int.self
    case .Double: return Swift.Double.self
    case .Boolean: return Swift.Bool.self
    case .Timestamp: return Tailor.Timestamp.self
    case .Time: return Tailor.Time.self
    case .Date: return Tailor.Date.self
    case .Data: return NSData.self
    }
  }
  
  //MARK: - Casting
  
  /**
  This method attempts to extract a string value from this value's contents.
  */
  public var stringValue: Swift.String? {
    switch(self) {
    case let .String(string):
      return string
    default:
      return nil
    }
  }
  
  /**
   This method attempts to extract a boolean value from this value's contents.
   */
  public var boolValue: Bool? {
    switch(self) {
    case let .Boolean(bool):
      return bool
    case let .Integer(int):
      return int == 1
    case .String("true"): return true
    case .String("false"): return false
    default:
      return nil
    }
  }
  
  /**
   This method attempts to extract an integer value from this value's contents.
   */
  public var intValue: Int? {
    switch(self) {
    case let .Integer(int):
      return int
    case let .String(string):
      return Int(string)
    default:
      return nil
    }
  }
  
  /**
   This method attempts to extract a data value from this value's contents.
   */
  public var dataValue: NSData? {
    switch(self) {
    case let .Data(data):
      return data
    default:
      return nil
    }
  }
  
  /**
   This method attempts to extract a double value from this value's contents.
   */
  public var doubleValue: Swift.Double? {
    switch(self) {
    case let .Double(double):
      return double
    case let .String(string):
      return Swift.Double(string)
    default:
      return nil
    }
  }
  
  /**
   This method attempts to extract a foundation date value from this value's
   contents.
   */
  public var foundationDateValue: NSDate? {
    return self.timestampValue?.foundationDateValue
  }
  
  /**
   This method attempts to extract a timestamp value from this value's
   contents.
   */
  public var timestampValue: Tailor.Timestamp? {
    switch(self) {
    case let .Timestamp(timestamp):
      return timestamp
    case let .String(string):
      return TimeFormat.Database.parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar())
    default:
      return nil
    }
  }
  
  /**
   This method attempts to extract a date value from this value's contents.
   */
  public var dateValue: Tailor.Date? {
    switch(self) {
    case let .Date(date):
      return date
    case let .Timestamp(timestamp):
      return timestamp.date
    case let .String(string):
      return TimeFormat(.Year, "-", .Month, "-", .Day).parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar())?.date
    default:
      return nil
    }
  }
  
  /**
   This method attempts to extract a time value from this value's contents.
   */
  public var timeValue: Tailor.Time? {
    switch(self) {
    case let .Time(time):
      return time
    case let .Timestamp(timestamp):
      return timestamp.time
    case let .String(string):
      return TimeFormat(.Hour, ":", .Minute, ":", .Seconds).parseTime(string, timeZone: Application.sharedDatabaseConnection().timeZone, calendar: SystemCalendar())?.time
    default:
      return nil
    }
  }
  
  /**
   This method gets a description of the underlying value for debugging.
   */
  public var valueDescription: Swift.String {
    switch(self) {
    case let .String(string):
      return string
    case let .Boolean(bool):
      return bool.description
    case let .Data(data):
      return data.description
    case let .Integer(int):
      return Swift.String(int)
    case let .Double(double):
      return double.description
    case let .Timestamp(timestamp):
      return timestamp.format(TimeFormat.Database)
    case let .Date(date):
      return date.description
    case let .Time(time):
      return time.description
    case let .Array(array):
      return array.description
    case let .Dictionary(dictionary):
      return dictionary.description
    case .Null:
      return "NULL"
    }
  }
  
  //MARK: - Parsing Data
  
  /**
   This method reads the value that this primitive wraps around.
   
   This infers the desired output type from the caller context. If that desired
   type doesn't match what this wraps around, this will throw a
   `SerializationParsingError.WrongFieldType` error.
   
   - returns:    The unwrapped value.
   */
  public func read<OutputType>() throws -> OutputType {
    switch(OutputType.self) {
    case is Swift.String.Type:
      if let cast = self.stringValue as? OutputType {
        return cast
      }
    case is Int.Type:
      if let cast = self.intValue as? OutputType { return cast }
    case is UInt.Type:
      if let int = self.intValue, let cast = UInt(int) as? OutputType { return cast }
    case is Tailor.Timestamp.Type:
      if let cast = self.timestampValue as? OutputType { return cast }
    case is Tailor.Date.Type:
      if let cast = self.dateValue as? OutputType { return cast }
    case is Tailor.Time.Type:
      if let cast = self.timeValue as? OutputType { return cast }
    case is NSData.Type:
      if let cast = self.dataValue as? OutputType { return cast }
    case is Swift.Double.Type:
      if let cast = self.doubleValue as? OutputType { return cast }
    case is Bool.Type:
      if let cast = self.boolValue as? OutputType { return cast }
    default:
      break
    }
    throw SerializationParsingError.WrongFieldType(field: "root", type: OutputType.self, caseType: self.wrappedType)
  }
  
  /**
   This method reads the value from a key in a JSON dictionary.
   
   This will infer the desired return type from the caller context.
   
   If this is not a dictionary type, this will throw a
   `SerializationParsingError.WrongFieldType` error. If the value that the dictionary
   has for that key does not match the desired type, this will throw a
   `SerializationParsingError.WrongFieldType` error. If there is no field on the
   dictionary for the desired key, this will throw a
   `SerializationParsingError.MissingField` error.
   
   - parameter key:    The name of the key to read.
   - returns:          The unwrapped value.
   */
  public func read<OutputType>(key: Swift.String) throws -> OutputType {
    let value: SerializableValue = try self.read(key)
    do {
      return try value.read()
    }
    catch SerializationParsingError.WrongFieldType(field: _, type: let type, caseType: let caseType) {
      throw SerializationParsingError.WrongFieldType(field: key, type: type, caseType: caseType)
    }
    catch let e {
      throw e
    }
  }
  
  /**
   This method reads a primitive from a key in a JSON dictionary.
   
   If this is not a dictionary type, this will throw a
   `SerializationParsingError.WrongFieldType` error. If there is no field on the
   dictionary for the desired key, this will throw a
   `SerializationParsingError.MissingField` error.
   
   - parameter key:    The name of the key to read.
   - returns:          The primitive at that key.
   */
  public func read(key: Swift.String) throws -> SerializableValue {
    let dictionary = try self.read() as [Swift.String:SerializableValue]
    guard let value = dictionary[key] else {
      throw SerializationParsingError.MissingField(field: key)
    }
    return value
  }
  
  /**
   This method takes a value from a key in a JSON dictionary and uses it to
   populate an instance of a JSON-convertible type.
   
   If the output type throws a parsing error when building itself, this will
   add the key as a prefix to the field name in the parsing error. So if the
   key here is "hat", and the Hat constructor throws an error over a missing
   "size" variable, this call will throw a MissingField error with a field
   of "hat.size". This allows us to build full key paths as we push errors up
   a parsing call stack.
   
   - parameter key:    The key to fetch
   - parameter into:   The type that we should build with the value at that
   key.
   - returns:          The newly constructed value in the output type.
   */
  public func read<T: SerializationInitializable>(key: Swift.String, into: T.Type) throws -> T {
    let value: SerializableValue = try self.read(key)
    return try SerializationParsingError.withFieldPrefix(key) { return try T(value: value) }
  }
}

/**
 This method determines if two JSON primitives are equal.
 
 - parameter lhs:    The left-hand side of the operator.
 - parameter rhs:    The right-hand side of the operator.
 - returns:          Whether the two are equal.
 */
public func ==(lhs: SerializableValue, rhs: SerializableValue) -> Bool {
  switch(lhs) {
  case let .String(string1):
    if case let .String(string2) = rhs { return string1 == string2 }
  case let .Integer(int1):
    if case let .Integer(int2) = rhs { return int1 == int2 }
  case let .Boolean(bool1):
    if case let .Boolean(bool2) = rhs { return bool1 == bool2 }
  case let .Double(double1):
    if case let .Double(double2) = rhs { return double1 == double2 }
  case let .Data(data1):
    if case let .Data(data2) = rhs { return data1 == data2 }
  case let .Timestamp(timestamp1):
    if case let .Timestamp(timestamp2) = rhs { return timestamp1 == timestamp2 }
  case let .Time(time1):
    if case let .Time(time2) = rhs { return time1 == time2 }
  case let .Date(date1):
    if case let .Date(date2) = rhs { return date1 == date2 }
  case let .Array(array1):
    if case let .Array(array2) = rhs { return array1 == array2 }
  case let .Dictionary(dictionary1):
    if case let .Dictionary(dictionary2) = rhs { return dictionary1 == dictionary2 }
  case .Null:
    if case .Null = rhs { return true }
  }
  return false
}


extension SerializableValue {
  /**
   This method gets the object that this enum case wraps around.
   
   This is designed to be fed into the methods in NSJSONSerialization, though
   the return value may not be a valid JSON object by that class's rules.
   */
  public var toFoundationJsonObject: AnyObject {
    switch(self) {
    case let String(string):
      return string
    case let Array(array):
      return array.map { $0.toFoundationJsonObject }
    case let Dictionary(dictionary):
      var results : [Swift.String:AnyObject] = [:]
      for (key,value) in dictionary {
        results[key] = value.toFoundationJsonObject
      }
      return results
    case Null:
      return NSNull()
    case let Integer(number):
      return NSNumber(integer: number)
    case let Double(number):
      return NSNumber(double: number)
    case let Boolean(boolean):
      return NSNumber(bool: boolean)
    case let Timestamp(timestamp):
      return timestamp.format(TimeFormat.Database)
    case let Time(time):
      return time.description
    case let Date(date):
      return date.description
    case let Data(data):
      return data
    }
  }
  
  /**
   This method gets the encoded JSON data.
   
   This can throw a `JsonConversionError`, or anything that
   `NSJSONSerialization.dataWithJSONObject can throw.
   */
  public func jsonData() throws -> NSData {
    let object = self.toFoundationJsonObject
    if !NSJSONSerialization.isValidJSONObject(object) {
      throw SerializationConversionError.NotValidJsonObject
    }
    return try NSJSONSerialization.dataWithJSONObject(object, options: [])
  }

  
  /**
   This method initializes a JSON primitive with JSON data.
   
   This method can throw whatever `NSJSONSerialization.JSONObjectWithData`
   throws. It can also throw a method if the decoded JSON object has a type
   that we do not yet support.
   
   - parameter jsonData:   The JSON data.
   */
  public init(jsonData: NSData) throws {
    let object = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
    try self.init(jsonObject: object)
  }
  
  /**
   This method initializes a JSON primitive with a raw JSON object.
   
   This can be a String, Dictionary, Array, or anything else that has a
   designated SerializableValue wrapper. In the case of dictionaries or arrays,
   the values contained within them should be raw JSON objects themselves,
   rather than SerializableValues.
   
   This will throw a `SerializationParsingError` if the object is not a type that we
   can use to build a primitive.
   
   - parameter jsonObject:   The JSON object.
   */
  public init(jsonObject: AnyObject) throws {
    if let s = jsonObject as? Swift.String {
      self = String(s)
    }
    else if let d = jsonObject as? [Swift.String:AnyObject] {
      var mappedDictionary: [Swift.String: SerializableValue] = [:]
      for (key,value) in d {
        mappedDictionary[key] = try SerializableValue(jsonObject: value)
      }
      self = Dictionary(mappedDictionary)
    }
    else if let a = jsonObject as? [AnyObject] {
      var mappedArray = [SerializableValue]()
      for value in a {
        try mappedArray.append(SerializableValue(jsonObject: value))
      }
      self = Array(mappedArray)
    }
    else if jsonObject is NSNull {
      self = Null
    }
    else if let n = jsonObject as? NSNumber {
      if Swift.Double(n.integerValue) == n.doubleValue {
        self = Integer(n.integerValue)
      }
      else {
        self = Double(n.doubleValue)
      }
    }
    else {
      throw SerializationParsingError.UnsupportedType(jsonObject.dynamicType)
    }
  }
}

extension SerializableValue {
  /**
   This method loads JSON data from a plist file.
   
   This allows us to extract data from a plist file using the convenience
   methods for fetching data from JSON.
   
   - parameter path:   The path to the plist file.
   - throws:           A `JsonConversionError`.
   */
  public init(plist path: Swift.String) throws {
    guard let data = NSData(contentsOfFile: path) else {
      NSLog("Error reading plist at path %@", path)
      NSLog("Could not open file")
      throw SerializationConversionError.NotValidJsonObject
    }
    let contents = try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil)
    try self.init(jsonObject: contents)
  }
}

extension SerializableValue {
  
  /**
   This method reads a value from our data dictionary and attempts to cast it
   to another type.
   
   This will infer the desired return type from the calling context.
   
   This method wraps around the other version of `read` which returns a
   non-optional type. If the value is missing, or is a null database value,
   this will return nil.
   
   - parameter key:    The key to read.
   - returns:          The cast value.
   - throws:           An exception from `DatabaseError`.
   */
  public func read<OutputType: SerializationConvertible>(key: Swift.String) throws -> OutputType? {
    switch(self) {
    case let .Dictionary(data):
      guard let value = data[key] else { return nil }
      if value == .Null { return nil }
      if value == .String("") { return nil }
      let result: OutputType = try self.read(key)
      return result
    default:
      return nil
    }
  }
  
  
  /**
   This method reads a row from the database from an id fetched from another
   table.
   
   - parameter fieldName:    The name of the field that contains the id.
   - returns:                The fetched record.
   - throws:                 A DatabaseError explaining why we couldn't fetch
   the record.
   */
  public func read<RecordType: Persistable>(fieldName: Swift.String) throws -> RecordType? {
    guard let id = try read(fieldName) as Int? else { return nil }
    return Query<RecordType>().find(id)
  }
  
  /**
   This method reads a row from the database from an id fetched from another
   table.
   
   - parameter fieldName:    The name of the field that contains the id.
   - returns:                The fetched record.
   - throws:                 A DatabaseError explaining why we couldn't fetch
   the record.
   */
  public func read<RecordType: Persistable>(fieldName: Swift.String) throws -> RecordType {
    guard let record = try self.read(fieldName) as RecordType? else {
      throw DatabaseError.MissingField(name: fieldName)
    }
    return record
  }
  
  /**
   This method reads an enum case from a row in the database.
   
   - parameter fieldName:    The name of the field that contains the id.
   - returns:                The fetched value.
   - throws:                 A DatabaseError explaining why we couldn't fetch
   the value.
   */
  public func readEnum<EnumType: TablePersistableEnum>(id fieldName: Swift.String) throws -> EnumType? {
    guard let id = try read(fieldName) as Int? else { return nil }
    return EnumType.fromId(id)
  }
  
  /**
   This method reads an enum case from a row in the database.
   
   - parameter fieldName:    The name of the field that contains the id.
   - returns:                The fetched value.
   - throws:                 A DatabaseError explaining why we couldn't fetch
   the value.
   */
  public func readEnum<EnumType: TablePersistableEnum>(id fieldName: Swift.String) throws -> EnumType {
    guard let record = try self.readEnum(id: fieldName) as EnumType? else {
      throw DatabaseError.MissingField(name: fieldName)
    }
    return record
  }
  
  /**
   This method reads an enum case from a row in the database.
   
   - parameter fieldName:    The name of the field that contains the case name.
   - returns:                The fetched value.
   - throws:                 A DatabaseError explaining why we couldn't fetch
   the value.
   */
  public func readEnum<EnumType: PersistableEnum>(name fieldName: Swift.String) throws -> EnumType? {
    guard let name = try read(fieldName) as Swift.String? else { return nil }
    return EnumType.fromCaseName(name)
  }
  
  
  /**
   This method reads an enum case from a row in the database.
   
   - parameter fieldName:    The name of the field that contains the case name.
   - returns:                The fetched value.
   - throws:                 A DatabaseError explaining why we couldn't fetch
   the value.
   */
  public func readEnum<EnumType: PersistableEnum>(name fieldName: Swift.String) throws -> EnumType {
    guard let record = try self.readEnum(name: fieldName) as EnumType? else {
      throw DatabaseError.MissingField(name: fieldName)
    }
    return record
  }
}