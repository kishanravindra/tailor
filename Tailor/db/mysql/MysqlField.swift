/**
  This class provides a wrapper around the MySQL field data structure.
  */
public class MysqlField {
  /** The raw field data. */
  private let field: MYSQL_FIELD
  
  /** The name of the field. */
  public let name: String
  
  /** The size of the items in the buffer. */
  public let bufferSize: UInt
  
  /** The number of items in the buffer. */
  public let bufferLength: UInt
  
  /** The type of data in the buffer. */
  public let bufferType: enum_field_types
  
  /** Whether this is a binary field. */
  public let isBinary: Bool
  
  /**
    This method initializes the field.

    :param: field   The raw field data.
    */
  public init(field: MYSQL_FIELD) {
    self.field = field
    
    if let name = NSString(bytes: field.name, length: Int(field.name_length), encoding: NSASCIIStringEncoding) as? String {
      self.name = name
    }
    else {
      self.name = ""
    }
    
    self.bufferType = field.type
    self.isBinary = (field.charsetnr == 63) && (
      field.type.value == MYSQL_TYPE_BLOB.value ||
      field.type.value == MYSQL_TYPE_TINY_BLOB.value ||
      field.type.value == MYSQL_TYPE_MEDIUM_BLOB.value ||
      field.type.value == MYSQL_TYPE_LONG_BLOB.value
    )
    (self.bufferSize, self.bufferLength) = MysqlField.bufferSize(field.type)
  }
  
  /**
    This method gets the size of a buffer for holding a MySQL field.

    :returns:
      A tuple holding the size of the itmes in the buffer and the number of
      itmes. in the buffer.
    */
  public class func bufferSize(type: enum_field_types) -> (size: UInt, count: UInt) {
    var size = UInt(sizeof(UInt8))
    var length = UInt(1)
    switch type.value {
    case MYSQL_TYPE_TINY.value, MYSQL_TYPE_BIT.value:
      size = UInt(sizeof(CChar))
    case MYSQL_TYPE_SHORT.value:
      size = UInt(sizeof(CShort))
    case MYSQL_TYPE_LONG.value, MYSQL_TYPE_INT24.value:
      size = UInt(sizeof(CInt))
    case MYSQL_TYPE_LONGLONG.value:
      size = UInt(sizeof(CLongLong))
    case MYSQL_TYPE_FLOAT.value:
      size = UInt(sizeof(CFloat))
    case MYSQL_TYPE_DOUBLE.value:
      size = UInt(sizeof(CDouble))
    case MYSQL_TYPE_TIME.value, MYSQL_TYPE_DATE.value, MYSQL_TYPE_DATETIME.value,  MYSQL_TYPE_TIMESTAMP.value:
      size = UInt(sizeof(MYSQL_TIME))
    case MYSQL_TYPE_TINY_BLOB.value:
      length = 1 << 8
    case MYSQL_TYPE_BLOB.value:
      length = 1 << 16
    case MYSQL_TYPE_MEDIUM_BLOB.value:
      length = 1 << 24
      break;
    case MYSQL_TYPE_LONG_BLOB.value:
      length = 1 << 31
    default:
      length = 1024
    }
    return (size,length)
  }
}