import Tailor

struct ___FILEBASENAME___ : Persistable, Equatable {
  /** The id for the record. */
  let id: UInt

  /**
    This method initializes a record from a row in the database.

    You should extract the fields that your record needs, and return nil if any
    required fields are missing.

    - parameter values:  The row in the database.
    */
  init(deserialize values: SerializableValue) throws {
    id = try values.read("id")
  }
  
  /**
    This method gets the columns that we will save in the database for a record.

    You must add the mapping for your fields here.
    */
  func valuesToPersist() -> [String : SerializationEncodable?] {
    return [:]
  }
  
  /** A query for fetching records. */
  static let query = Query<___FILEBASENAME___>()
}