import mysql

/**
  This class wraps around a MySQL bind parameter to provide easier access to
  metadata and field values.
  */
public struct MysqlBindParameter: Equatable {
  /** The raw MySQL bind parameter. */
  public let parameter: MYSQL_BIND
  
  /** Whether the field is a binary field. */
  let binary: Bool
  
  //MARK: - Creation
  
  /**
    This method initializes a field with an empty bind parameter.
    */
  public init() {
    parameter = MYSQL_BIND()
    binary = false
  }

  /**
    This method creates a bind parameter wrapping around a raw MySQL parameter.

    - parameter parameter:   The raw parameter.
    */
  public init(parameter: MYSQL_BIND) {
    self.parameter = parameter
    binary = false
  }
  
  /**
    This method creates a bind parameter for holding an output value for a
    field.
  
    - parameter field:   The metadata for the field.
    */
  public init(field: MysqlField) {
    let buffer = calloc(Int(field.bufferLength), Int(field.bufferSize));
    var parameter = MYSQL_BIND()
    parameter.buffer = buffer;
    parameter.buffer_type = field.bufferType;
    parameter.buffer_length = UInt(field.bufferLength)
    
    parameter.length = UnsafeMutablePointer<UInt>(malloc(sizeof(NSInteger)));
    parameter.length.memory = 0;
    
    parameter.is_null = UnsafeMutablePointer<my_bool>(malloc(sizeof(my_bool)));
    parameter.is_null.memory = 0;
    
    parameter.error = UnsafeMutablePointer<my_bool>(malloc(sizeof(my_bool)));
    parameter.error.memory = 0;
    
    self.parameter = parameter
    self.binary = field.isBinary;
  }
  
  /**
    This method creates a bind parameter for holding an input value.

    - parameter value:    The input value.
    */
  public init(value: DatabaseValue) {
    var parameter = MYSQL_BIND()
    
    var data: NSData? = nil
    var mysqlTime: MYSQL_TIME? = nil
    
    switch(value) {
    case let .String(string):
      data = string.dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    case let .Integer(int):
      data = String(int).dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    case let .Boolean(bool):
      let int = bool ? 1 : 0
      data = String(int).dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    case let .Double(double):
      data = "\(double)".dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    case let .Data(wrappedData):
      data = wrappedData
    case let .Timestamp(timestamp):
      let timestamp = timestamp.inTimeZone(DatabaseConnection.sharedConnection().timeZone)
      mysqlTime = MYSQL_TIME(
        year: UInt32(timestamp.year),
        month: UInt32(timestamp.month),
        day: UInt32(timestamp.day),
        hour: UInt32(timestamp.hour),
        minute: UInt32(timestamp.minute),
        second: UInt32(timestamp.second),
        second_part: UInt(timestamp.nanosecond / 1000),
        neg: 0,
        time_type: MYSQL_TIMESTAMP_DATETIME
      )
    case let .Time(time):
      mysqlTime = MYSQL_TIME(
        year: 0,
        month: 0,
        day: 0,
        hour: UInt32(time.hour),
        minute: UInt32(time.minute),
        second: UInt32(time.second),
        second_part: UInt(time.nanosecond / 1000),
        neg: 0,
        time_type: MYSQL_TIMESTAMP_TIME
      )
    case let .Date(date):
      mysqlTime = MYSQL_TIME(
        year: UInt32(date.year),
        month: UInt32(date.month),
        day: UInt32(date.day),
        hour: 0,
        minute: 0,
        second: 0,
        second_part: 0,
        neg: 0,
        time_type: MYSQL_TIMESTAMP_DATE
      )
    case .Null:
      data = NSData()
    }
    if let data = data {
      parameter.buffer = malloc(data.length)
      memcpy(parameter.buffer, data.bytes, data.length)
      parameter.buffer_length = UInt(data.length)
      parameter.buffer_type = MYSQL_TYPE_STRING
    }
    if let time = mysqlTime {
      
      let buffer = UnsafeMutablePointer<MYSQL_TIME>(calloc(sizeof(MYSQL_TIME), 1))
      buffer.memory = time
      parameter.buffer = UnsafeMutablePointer<Void>(buffer)
      parameter.buffer_length = 1
      switch(time.time_type.rawValue) {
      case MYSQL_TIMESTAMP_TIME.rawValue:
        parameter.buffer_type = MYSQL_TYPE_TIME
      case MYSQL_TIMESTAMP_DATE.rawValue:
        parameter.buffer_type = MYSQL_TYPE_DATE
      case MYSQL_TIMESTAMP_DATETIME.rawValue:
        parameter.buffer_type = MYSQL_TYPE_TIMESTAMP
      default:
        parameter.buffer_type = MYSQL_TYPE_TIMESTAMP
      }
    }
    self.parameter = parameter
    self.binary = false
  }
  
  //MARK: - Field Information
  
  /** Whether the field has a null value. */
  public var isNull: Bool { return parameter.is_null.memory != 0 }
  
  /** The buffer that holds the return values. */
  public var buffer: UnsafeMutablePointer<Void> { return parameter.buffer }
  
  /** The length of the buffer. */
  public var length: UInt { return parameter.length.memory }
  
  /** The type of the parameter. */
  public var type: enum_field_types { return parameter.buffer_type }
  
  /**
    This method returns the data from the parameter.

    The data will be wrapped in our database value enum.

    - returns:   The converted data.
    */
  public func data() -> DatabaseValue {
    if(self.isNull) {
      return DatabaseValue.Null;
    }
                
    switch(self.type.rawValue) {
    case MYSQL_TYPE_TINY.rawValue, MYSQL_TYPE_BIT.rawValue:
      let buffer = UnsafePointer<CChar>(self.buffer)
      return Int(buffer.memory).databaseValue
    case MYSQL_TYPE_SHORT.rawValue:
      let buffer = UnsafePointer<CShort>(self.buffer)
      return Int(buffer.memory).databaseValue
    case MYSQL_TYPE_LONG.rawValue, MYSQL_TYPE_INT24.rawValue:
      let buffer = UnsafePointer<CInt>(self.buffer)
      return Int(buffer.memory).databaseValue
    case MYSQL_TYPE_LONGLONG.rawValue:
      let buffer = UnsafePointer<CLongLong>(self.buffer)
      return Int(buffer.memory).databaseValue
    case MYSQL_TYPE_FLOAT.rawValue:
      let buffer = UnsafePointer<CFloat>(self.buffer)
      return Double(buffer.memory).databaseValue
    case MYSQL_TYPE_DOUBLE.rawValue:
      let buffer = UnsafePointer<CDouble>(self.buffer)
      return Double(buffer.memory).databaseValue
    case MYSQL_TYPE_NEWDECIMAL.rawValue:
      let buffer = UnsafePointer<CChar>(self.buffer)
      let string = NSString(bytes: buffer, length: Int(self.length), encoding: NSUTF8StringEncoding)
      return string?.doubleValue.databaseValue ?? DatabaseValue.Null
    case MYSQL_TYPE_TIME.rawValue:
      let buffer = UnsafePointer<MYSQL_TIME>(self.buffer)
      return  MysqlBindParameter.timestampFromTime(buffer.memory).time.databaseValue ?? DatabaseValue.Null
    case MYSQL_TYPE_DATE.rawValue:
      let buffer = UnsafePointer<MYSQL_TIME>(self.buffer)
      return MysqlBindParameter.timestampFromTime(buffer.memory).date.databaseValue ?? DatabaseValue.Null
    case MYSQL_TYPE_DATETIME.rawValue, MYSQL_TYPE_TIMESTAMP.rawValue:
      let buffer = UnsafePointer<MYSQL_TIME>(self.buffer)
      return MysqlBindParameter.timestampFromTime(buffer.memory).databaseValue ?? DatabaseValue.Null
    case MYSQL_TYPE_TINY_BLOB.rawValue, MYSQL_TYPE_BLOB.rawValue, MYSQL_TYPE_MEDIUM_BLOB.rawValue, MYSQL_TYPE_LONG_BLOB.rawValue:
      if binary {
        return NSData(bytes: self.buffer, length: Int(self.length)).databaseValue
      }
      else {
        let string = NSString(bytes: self.buffer, length: Int(self.length), encoding: NSUTF8StringEncoding) as? String
        return string?.databaseValue ?? DatabaseValue.Null
      }
    default:
      let string =  NSString(bytes: self.buffer, length: Int(self.length), encoding: NSUTF8StringEncoding) as? String
      return string?.databaseValue ?? DatabaseValue.Null
    }
  }
  
  /**
    This method converts a MySQL time data structure into a timestamp.

    - parameter time:     The MySQL time
    - returns:            The timestamp
    */
  public static func timestampFromTime(time: MYSQL_TIME) -> Timestamp {
    return Timestamp(
      year: Int(time.year),
      month: Int(time.month),
      day: Int(time.day),
      hour: Int(time.hour),
      minute: Int(time.minute),
      second: Int(time.second),
      nanosecond: 0,
      timeZone: DatabaseConnection.sharedConnection().timeZone
    )
  }
}

/**
  This method determines if two bind parameters are equal.

  Bind parameters are equal if they have the same buffer, length, and buffer
  type.

  - parameter lhs:    The left hand side of the operator
  - parameter rhs:    The right hand side of the operator
  - returns:          Whether the two bind parameters are equal.
  */
public func ==(lhs: MysqlBindParameter, rhs: MysqlBindParameter) -> Bool {
  return lhs.buffer == rhs.buffer &&
    lhs.length == rhs.length &&
    lhs.type == rhs.type
}