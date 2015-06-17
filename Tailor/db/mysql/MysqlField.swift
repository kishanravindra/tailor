import mysql
import Foundation

/**
  This class provides a wrapper around the MySQL field data structure.
  */
public struct MysqlField {
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

    - parameter field:   The raw field data.
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
      field.type.rawValue == MYSQL_TYPE_BLOB.rawValue ||
      field.type.rawValue == MYSQL_TYPE_TINY_BLOB.rawValue ||
      field.type.rawValue == MYSQL_TYPE_MEDIUM_BLOB.rawValue ||
      field.type.rawValue == MYSQL_TYPE_LONG_BLOB.rawValue
    )
    (self.bufferSize, self.bufferLength) = MysqlField.bufferSize(field.type)
  }
  
  /**
    This method gets the size of a buffer for holding a MySQL field.

    - returns:  A tuple holding the size of the itmes in the buffer and the
                number of items in the buffer.
    */
  public static func bufferSize(type: enum_field_types) -> (size: UInt, count: UInt) {
    var size = UInt(sizeof(UInt8))
    var length = UInt(1)
    switch type.rawValue {
    case MYSQL_TYPE_TINY.rawValue, MYSQL_TYPE_BIT.rawValue:
      size = UInt(sizeof(CChar))
    case MYSQL_TYPE_SHORT.rawValue:
      size = UInt(sizeof(CShort))
    case MYSQL_TYPE_LONG.rawValue, MYSQL_TYPE_INT24.rawValue:
      size = UInt(sizeof(CInt))
    case MYSQL_TYPE_LONGLONG.rawValue:
      size = UInt(sizeof(CLongLong))
    case MYSQL_TYPE_FLOAT.rawValue:
      size = UInt(sizeof(CFloat))
    case MYSQL_TYPE_DOUBLE.rawValue:
      size = UInt(sizeof(CDouble))
    case MYSQL_TYPE_TIME.rawValue, MYSQL_TYPE_DATE.rawValue, MYSQL_TYPE_DATETIME.rawValue,  MYSQL_TYPE_TIMESTAMP.rawValue:
      size = UInt(sizeof(MYSQL_TIME))
    case MYSQL_TYPE_TINY_BLOB.rawValue:
      length = 1 << 8
    case MYSQL_TYPE_BLOB.rawValue:
      length = 1 << 16
    case MYSQL_TYPE_MEDIUM_BLOB.rawValue:
      length = 1 << 24
      break;
    case MYSQL_TYPE_LONG_BLOB.rawValue:
      length = 1 << 31
    default:
      length = 1024
    }
    return (size,length)
  }
}