/**
  This class wraps around a MySQL bind parameter to provide easier access to
  metadata and field values.
  */
public class MysqlBindParameter {
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

    :param: data    The input data.
    */
  public init(data: NSData) {
    var parameter = MYSQL_BIND()
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

    The data will be marshalled into an appropriate Swift type based on the
    metadata.

    This will return an NSNumber, an NSString, an NSDate, or an NSData.

    :returns:   The converted data.
    */
  public func data() -> Any? {
    var stringValue: String? = nil;
    
    if(self.isNull) {
      return nil;
    }
                
    switch(self.parameter.buffer_type.value) {
    case MYSQL_TYPE_TINY.value, MYSQL_TYPE_BIT.value:
      let buffer = UnsafePointer<CChar>(self.buffer)
      return NSNumber(char: buffer.memory)
    case MYSQL_TYPE_SHORT.value:
      let buffer = UnsafePointer<CShort>(self.buffer)
      return NSNumber(short: buffer.memory)
    case MYSQL_TYPE_LONG.value, MYSQL_TYPE_INT24.value:
      let buffer = UnsafePointer<CInt>(self.buffer)
      return NSNumber(int: buffer.memory)
    case MYSQL_TYPE_LONGLONG.value:
      let buffer = UnsafePointer<CLongLong>(self.buffer)
      return NSNumber(longLong: buffer.memory)
    case MYSQL_TYPE_FLOAT.value:
      let buffer = UnsafePointer<CFloat>(self.buffer)
      return NSNumber(float: buffer.memory)
    case MYSQL_TYPE_DOUBLE.value:
      let buffer = UnsafePointer<CDouble>(self.buffer)
      return NSNumber(double: buffer.memory)
    case MYSQL_TYPE_NEWDECIMAL.value:
      let buffer = UnsafePointer<CChar>(self.buffer)
      let string = NSString(bytes: buffer, length: Int(self.length), encoding: NSUTF8StringEncoding)
      return string?.doubleValue
    case MYSQL_TYPE_TIME.value, MYSQL_TYPE_DATE.value, MYSQL_TYPE_DATETIME.value, MYSQL_TYPE_TIMESTAMP.value:
      let buffer = UnsafePointer<MYSQL_TIME>(self.buffer)
      return MysqlBindParameter.dateFromTime(buffer.memory)
    case MYSQL_TYPE_TINY_BLOB.value, MYSQL_TYPE_BLOB.value, MYSQL_TYPE_MEDIUM_BLOB.value, MYSQL_TYPE_LONG_BLOB.value:
      if binary {
        return NSData(bytes: self.buffer, length: Int(self.length))
      }
      else {
        return NSString(bytes: self.buffer, length: Int(self.length), encoding: NSUTF8StringEncoding)
      }
    default:
      return NSString(bytes: self.buffer, length: Int(self.length), encoding: NSUTF8StringEncoding)
    }
  }
  
  /**
    This method converts a MySQL time data structure into an NSDate data
    structure.

    :param: time    The MySQL time
    :returns:       The Foundation date
    */
  public static func dateFromTime(time: MYSQL_TIME) -> NSDate? {
    var components = NSDateComponents()
    components.year = Int(time.year)
    components.month = Int(time.month)
    components.day = Int(time.day)
    components.hour = Int(time.hour)
    components.minute = Int(time.minute)
    components.second = Int(time.second)
    components.timeZone = DatabaseConnection.sharedConnection().timeZone
    let calendar = NSCalendar.currentCalendar()
    return calendar.dateFromComponents(components)
  }
}