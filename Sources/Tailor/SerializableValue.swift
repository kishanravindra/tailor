import Foundation

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
  @available(*, deprecated)
  public var stringValue: Swift.String? {
    return try? Swift.String(deserialize: self)
  }
  
  /**
   This method attempts to extract a boolean value from this value's contents.
   */
  @available(*, deprecated)
  public var boolValue: Bool? {
    return try? Bool(deserialize: self)
  }
  
  /**
   This method attempts to extract an integer value from this value's contents.
   */
  @available(*, deprecated)
  public var intValue: Int? {
    return try? Int.init(deserialize: self)
  }
  
  /**
   This method attempts to extract a data value from this value's contents.
   */
  @available(*, deprecated)
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
  @available(*, deprecated)
  public var doubleValue: Swift.Double? {
    return try? Swift.Double.init(deserialize: self)
  }
  
  /**
   This method attempts to extract a foundation date value from this value's
   contents.
   */
  @available(*, deprecated)
  public var foundationDateValue: NSDate? {
    return self.timestampValue?.foundationDateValue
  }
  
  /**
   This method attempts to extract a timestamp value from this value's
   contents.
   */
  @available(*, deprecated)
  public var timestampValue: Tailor.Timestamp? {
    return try? Tailor.Timestamp(deserialize: self)
  }
  
  /**
   This method attempts to extract a date value from this value's contents.
   */
  @available(*, deprecated)
  public var dateValue: Tailor.Date? {
    return try? Tailor.Date(deserialize: self)
  }
  
  /**
   This method attempts to extract a time value from this value's contents.
   */
  @available(*, deprecated)
  public var timeValue: Tailor.Time? {
    return try? Tailor.Time(deserialize: self)
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
      return array.map { $0.valueDescription }.description
    case let .Dictionary(dictionary):
      return dictionary.map { return $0.valueDescription }.description
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
  public func read<OutputType: SerializationInitializable>() throws -> OutputType {
    return try OutputType.init(deserialize: self)
  }
  
  /**
    This method reads a value from a serialized dictionary and casts it to an
    output type.

    - parameter key:            The key that we are reading from our dictionary.
    - parameter valueFetcher:   A function for casting from the serialized value
                                for the key to the desired output type.
    */
  private func read<OutputType>(key: Swift.String, valueFetcher: (SerializableValue) throws -> OutputType) throws -> OutputType {
    func fullField(field: Swift.String) -> Swift.String {
      let result: Swift.String
      
      if field == "root" {
        result = key
      }
      else {
        result = key + "." + field
      }
      return result
    }
    let value = try self.read(key) as SerializableValue
    do {
      return try valueFetcher(value)
    }
    catch let SerializationParsingError.WrongFieldType(field: field, type: type, caseType: caseType) {
      throw SerializationParsingError.WrongFieldType(field: fullField(field), type: type, caseType: caseType)
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
    switch(self) {
    case let .Dictionary(dictionary):
      if let value = dictionary[key] {
        return value
      }
      else {
        throw SerializationParsingError.MissingField(field: key)
      }
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Swift.Dictionary<Swift.String,SerializableValue>.self, caseType: self.wrappedType)
    }
  }
  
  /**
   This method reads a value from a key in a JSON dictionary, and casts it into
    the desired type.
   
    If this is not a dictionary type, this will throw a
    `SerializationParsingError.WrongFieldType` error. If there is no field on
    the dictionary for the desired key, this will throw a
    `SerializationParsingError.MissingField` error. If the field in the
    dictionary is of the wrong type, this will throw a
    `SerializationParsingError.WrongFieldType`.
   
    - parameter key:    The name of the key to read.
    - returns:          The value at that key.
    */
  public func read<OutputType: SerializationInitializable>(key: Swift.String) throws -> OutputType {
    return try read(key) { try $0.read() }
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
    return try SerializationParsingError.withFieldPrefix(key) { return try T(deserialize: value) }
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
      return string.bridge()
    case let Array(array):
      return array.map { $0.toFoundationJsonObject }.bridge()
    case let Dictionary(dictionary):
      var results : [NSString:AnyObject] = [:]
      for (key,value) in dictionary {
        results[key.bridge()] = value.toFoundationJsonObject
      }
      return results.bridge()
    case Null:
      return NSNull()
    case let Integer(number):
      return NSNumber(integer: number)
    case let Double(number):
      return NSNumber(double: number)
    case let Boolean(boolean):
      return NSNumber(bool: boolean)
    case let Timestamp(timestamp):
      return timestamp.format(TimeFormat.Database).bridge()
    case let Time(time):
      return time.description.bridge()
    case let Date(date):
      return date.description.bridge()
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
   This method initializes a serialized value with JSON data.
   
   This method can throw whatever `NSJSONSerialization.JSONObjectWithData`
   throws. It can also throw a method if the decoded JSON object has a type
   that we do not yet support.
   
   - parameter jsonData:   The JSON data.
   */
  public init(jsonData: NSData) throws {
    if let object = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? AnyObject {
      try self.init(jsonObject: object)
    }
    else {
      throw SerializationConversionError.NotValidJsonObject
    }
  }
  
  /**
   This method initializes a serialized value with a raw JSON object.
   
   This can be a String, Dictionary, Array, or anything else that has a
   designated SerializableValue wrapper. In the case of dictionaries or arrays,
   the values contained within them should be raw JSON objects themselves,
   rather than SerializableValues.
   
   This will throw a `SerializationParsingError` if the object is not a type that we
   can use to build a primitive.
   
   - parameter jsonObject:   The JSON object.
   */
  public init(jsonObject: AnyObject) throws {
    if let s = jsonObject as? NSString {
      self = String(s.bridge())
    }
    else if let d = jsonObject as? NSDictionary {
      var mappedDictionary: [Swift.String: SerializableValue] = [:]
      for (key,value) in d {
        if let stringKey = key as? NSString {
          mappedDictionary[stringKey.bridge()] = try SerializableValue(jsonObject: value)
        }
      }
      self = Dictionary(mappedDictionary)
    }
    else if let a = jsonObject as? NSArray {
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
   This method loads serialized data from a plist file.
   
   - parameter path:   The path to the plist file.
   - throws:           A `SerializationConversionError`.
   */
  public init(plist path: Swift.String) throws {
    guard let data = NSData(contentsOfFile: path) else {
      NSLog("Error reading plist at path %@", path)
      NSLog("Could not open file")
      throw SerializationConversionError.NotValidJsonObject
    }
    if let contents = try NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil) as? AnyObject {
      try self.init(jsonObject: contents)
    }
    else {
      throw SerializationConversionError.NotValidJsonObject
    }
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
  public func read<OutputType: SerializationInitializable>(key: Swift.String) throws -> OutputType? {
    switch(self) {
    case let .Dictionary(data):
      guard let value = data[key] else { return nil }
      if value == .Null { return nil }
      if value == .String("") { return nil }
      let result: OutputType = try self.read(key)
      return result
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Swift.Dictionary<Swift.String,SerializableValue>.self, caseType: wrappedType)
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
  public func readRecord<RecordType: Persistable>(fieldName: Swift.String) throws -> RecordType? {
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
  public func readRecord<RecordType: Persistable>(fieldName: Swift.String) throws -> RecordType {
    guard let record = try self.readRecord(fieldName) as RecordType? else {
      throw SerializationParsingError.MissingField(field: fieldName)
    }
    return record
  }
  
  /**
   This method reads an enum case from a row in the database.
   
   This has been deprecated in favor of the version without a name for the
   parameter.
   
   - parameter fieldName:    The name of the field that contains the id.
   - returns:                The fetched value.
   - throws:                 A DatabaseError explaining why we couldn't fetch
   the value.
   */
  @available(*, deprecated, message="Use the version without a name for the parameter")
  public func readEnum<EnumType: TablePersistableEnum>(id fieldName: Swift.String) throws -> EnumType? {
    guard let id = try read(fieldName) as Int? else { return nil }
    return EnumType.fromId(id)
  }
  
  /**
   This method reads an enum case from a row in the database.
   
   This has been deprecated in favor of the version without a name for the
   parameter.
   
   - parameter fieldName:    The name of the field that contains the id.
   - returns:                The fetched value.
   - throws:                 A DatabaseError explaining why we couldn't fetch
                              the value.
   */
  @available(*, deprecated, message="Use the version without a name for the parameter")
  public func readEnum<EnumType: TablePersistableEnum>(id fieldName: Swift.String) throws -> EnumType {
    guard let record = try self.readEnum(id: fieldName) as EnumType? else {
      throw SerializationParsingError.MissingField(field: fieldName)
    }
    return record
  }
  
  /**
   This method reads an enum case from a row in the database.
   
   This has been deprecated in favor of the version without a name for the
   parameter.
   
   - parameter fieldName:    The name of the field that contains the case name.
   - returns:                The fetched value.
   - throws:                 A DatabaseError explaining why we couldn't fetch
   the value.
   */
  @available(*, deprecated, message="Use the version without a name for the parameter")
  public func readEnum<EnumType: PersistableEnum>(name fieldName: Swift.String) throws -> EnumType? {
    guard let name = try read(fieldName) as Swift.String? else { return nil }
    return EnumType.fromCaseName(name)
  }
  
  
  /**
    This method reads an enum case from a row in the database.
   
    This has been deprecated in favor of the version without a name for the
    parameter.
   
    - parameter fieldName:    The name of the field that contains the case name.
    - returns:                The fetched value.
    - throws:                 A DatabaseError explaining why we couldn't fetch
                              the value.
   */
  @available(*, deprecated, message="Use the version without a name for the parameter")
  public func readEnum<EnumType: PersistableEnum>(name fieldName: Swift.String) throws -> EnumType {
    guard let record = try self.readEnum(name: fieldName) as EnumType? else {
      throw SerializationParsingError.MissingField(field: fieldName)
    }
    return record
  }
  
  /**
   This method reads an enum case from a row in the database.
   
   - parameter fieldName:     The name of the field that contains the value.
   - returns:                 The fetched value.
   - throws:                  A SerializableError explaining why we couldn't fetch
                              the value.
   */
  public func readEnum<EnumType: PersistableEnum>(fieldName: Swift.String) throws -> EnumType? {
    guard let value = try read(fieldName) as SerializableValue? else { return nil }
    return EnumType.fromSerializableValue(value)
  }
  
  /**
   This method reads an enum case from a row in the database.
   
   - parameter fieldName:     The name of the field that contains the case name.
   - returns:                 The fetched value.
   - throws:                  A SerializableError explaining why we couldn't fetch
                              the value.
   */
  public func readEnum<EnumType: PersistableEnum>(fieldName: Swift.String) throws -> EnumType {
    guard let record = try self.readEnum(fieldName) as EnumType? else {
      throw SerializationParsingError.MissingField(field: fieldName)
    }
    return record
  }
  
  /**
    This method reads an enum case from a row in the database.
   
    This will read the value as a string, and then use `fromCaseName` to get the
    value. This is designed as an alternative to the normal `readEnum` method,
    which will interpret the field as an id and use the `fromId` method. This
    is a temporary workaround until we can use `self.dynamicType` in the
    `TablePersistableEnum` initializer.
   
    - parameter fieldName:      The name of the field that contains the value.
    - returns:                  The fetched value.
    - throws:                   A DatabaseError explaining why we couldn't fetch
                                the value.
    */
  internal func readEnumIndirect<EnumType: TablePersistableEnum>(fieldName: Swift.String) throws -> EnumType {
    let name = try read(fieldName) as Swift.String
    guard let enumCase = EnumType.fromCaseName(name) else {
      throw SerializationParsingError.MissingField(field: fieldName)
    }
    return enumCase
  }
  
  /**
    This method reads a list of serialized values from this value.

     - returns:    The list, cast to the desired output type.
     - throws:     If the value is not an array, this will throw a
                  `SerializationParsingError`.
    */
  public func read<OutputType: SerializationInitializable>() throws -> [OutputType] {
    switch(self) {
    case let .Array(array):
      return try array.map { try $0.read() as OutputType }
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Swift.Array<OutputType>.self, caseType: self.wrappedType)
    }
  }
  
  
  /**
    This method reads a list of serialized values from a key on this value.
     
    - param key:  The key from this dictionary to read.
    - returns:    The list, cast to the desired output type.
    - throws:     If this is not a dictionary, or the value at the key is not
                  an array, this will throw a `SerializationParsingError`.
    */
  public func read<OutputType: SerializationInitializable>(key: Swift.String) throws -> [OutputType] {
    return try read(key) { try $0.read() }
  }
  
  /**
    This method reads a dictionary of serialized values from this record.
     - returns:    The cast values.
     - throws:     If this is not a dictionary, this will throw a
                  `SerializationParsingError`.
    */
  public func read<OutputType: SerializationInitializable>() throws -> [Swift.String:OutputType] {
    switch(self) {
    case let .Dictionary(dictionary):
      var result = Swift.Dictionary<Swift.String,OutputType>()
      for (key,value) in dictionary {
        result[key] = try value.read() as OutputType
      }
      return result
    default:
      throw SerializationParsingError.WrongFieldType(field: "root", type: Swift.Dictionary<Swift.String,OutputType>.self, caseType: self.wrappedType)
    }
  }
  
  /**
    This method reads a dictionary from the value that is in a key on this
    dictionary.
   
    - parameter key:    The key that we are reading from.
    - returns:          The mapped dictionary.
    - throws:           If this is not a dictionary, or the value at the key is
                        not a dictionary, this will throw a
                        `SerializationParsingError`.
    */
  public func read<OutputType: SerializationInitializable>(key: Swift.String) throws -> [Swift.String:OutputType] {
    return try read(key) { try $0.read() }
  }
}