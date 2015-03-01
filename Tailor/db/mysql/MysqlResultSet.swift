import Foundation

/**
  This class provides a wrapper around a MySQL result set.
  */
@objc public class MysqlResultSet {
  /** The raw result set. */
  private let result: UnsafeMutablePointer<MYSQL_RES>
  
  /** The fields in the result set. */
  public let fields: [MysqlField]
  
  /** Whether the result set returns no data. */
  public var isEmpty : Bool { return result == nil }
  
  /**
    This method initializes a result set.

    :param: statement   The statement whose result set this represents.
    */
  init(statement: UnsafeMutablePointer<MYSQL_STMT>) {
    let result = mysql_stmt_result_metadata(statement)
    
    var fields = [MysqlField]()
    if result != nil {
      let numberOfFields = mysql_num_fields(result)
      for indexOfField in 0..<numberOfFields {
        let field = mysql_fetch_field_direct(result, UInt32(indexOfField)).memory
        fields.append(MysqlField(field: field))
      }
    }
    
    self.result = result
    self.fields = fields
  }
  
  /**
    This method clears up the underlying MySQL storage when the result set is
    deallocated.
    */
  deinit {
    mysql_free_result(self.result)
  }
}