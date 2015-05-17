import mysql

/**
  This class wraps around a MySQL bind parameter to provide easier access to
  metadata and field values.
  */
public struct MysqlBindParameter {
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

    :param: parameter   The raw parameter.
    */
  public init(parameter: MYSQL_BIND) {
    self.parameter = parameter
    binary = false
  }
  
  /**
    This method creates a bind parameter for holding an output value for a
    field.
  
    :param: field   The metadata for the field.
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

    :param: value    The input value.
    */
  public init(value: DatabaseValue) {
    var parameter = MYSQL_BIND()
    
    let data: NSData
    
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
      let string = timestamp.format(TimeFormat.Database)
      data = string.dataUsingEncoding(NSUTF8StringEncoding) ?? NSData()
    default:
      data = NSData()
    }
    parameter.buffer = malloc(data.length)
    memcpy(parameter.buffer, data.bytes, data.length)
    parameter.buffer_length = UInt(data.length);
    parameter.buffer_type = MYSQL_TYPE_STRING;
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
  
  /**
    This method returns the data from the parameter.

    The data will be wrapped in our database value enum.

    :returns:   The converted data.
    */
  public func data() -> DatabaseValue {
    var stringValue: String? = nil;
    
    if(self.isNull) {
      return DatabaseValue.Null;
    }
                
    switch(self.parameter.buffer_type.value) {
    case MYSQL_TYPE_TINY.value, MYSQL_TYPE_BIT.value:
      let buffer = UnsafePointer<CChar>(self.buffer)
      return Int(buffer.memory).databaseValue
    case MYSQL_TYPE_SHORT.value:
      let buffer = UnsafePointer<CShort>(self.buffer)
      return Int(buffer.memory).databaseValue
    case MYSQL_TYPE_LONG.value, MYSQL_TYPE_INT24.value:
      let buffer = UnsafePointer<CInt>(self.buffer)
      return Int(buffer.memory).databaseValue
    case MYSQL_TYPE_LONGLONG.value:
      let buffer = UnsafePointer<CLongLong>(self.buffer)
      return Int(buffer.memory).databaseValue
    case MYSQL_TYPE_FLOAT.value:
      let buffer = UnsafePointer<CFloat>(self.buffer)
      return Double(buffer.memory).databaseValue
    case MYSQL_TYPE_DOUBLE.value:
      let buffer = UnsafePointer<CDouble>(self.buffer)
      return Double(buffer.memory).databaseValue
    case MYSQL_TYPE_NEWDECIMAL.value:
      let buffer = UnsafePointer<CChar>(self.buffer)
      let string = NSString(bytes: buffer, length: Int(self.length), encoding: NSUTF8StringEncoding)
      return string?.doubleValue.databaseValue ?? DatabaseValue.Null
    case MYSQL_TYPE_TIME.value, MYSQL_TYPE_DATE.value, MYSQL_TYPE_DATETIME.value, MYSQL_TYPE_TIMESTAMP.value:
      let buffer = UnsafePointer<MYSQL_TIME>(self.buffer)
      return MysqlBindParameter.timestampFromTime(buffer.memory)?.databaseValue ?? DatabaseValue.Null
    case MYSQL_TYPE_TINY_BLOB.value, MYSQL_TYPE_BLOB.value, MYSQL_TYPE_MEDIUM_BLOB.value, MYSQL_TYPE_LONG_BLOB.value:
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

    :param: time    The MySQL time
    :returns:       The timestamp
    */
  public static func timestampFromTime(time: MYSQL_TIME) -> Timestamp? {
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