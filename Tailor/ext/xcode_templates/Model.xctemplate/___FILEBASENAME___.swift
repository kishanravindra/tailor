import Tailor

struct ___FILEBASENAME___ : Persistable {
  /** The id for the record. */
  let id: Int?

  /**
    This method initializes a record from a row in the database.

    You should extract the fields that your record needs, and return nil if any
    required fields are missing.

    :param: databaseRow   The row in the database.
    */
  init(databaseRow: DatabaseRow) throws {
    self.id = try databaseRow.read("id")
  }
  
  /**
    This method gets the columns that we will save in the database for a record.

    You must add the mapping for your fields here.
    */
  func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return [:]
  }
  
  /** The name of the table that holds posts. */
  static var tableName: String { return "___FILEBASENAME___s" }
}