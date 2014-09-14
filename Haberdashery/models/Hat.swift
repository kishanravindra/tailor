import Foundation

/**
  This class models a hat in our Haberdashery.
  */
class Hat : Record {
  //MARK: - Structure
  
  /** The size of the hat's brim. */
  dynamic var brimSize : NSNumber!
  
  /** The color of the hat. */
  dynamic var color : String!
  
  /** The date when the record was created. */
  dynamic private(set) var createdAt : NSDate!
  
  /** The date when the record was last updated. */
  dynamic private(set) var updatedAt : NSDate!
  
  /** The name of the table that backs this class. */
  override class func tableName() -> String { return "hats" }
  
  /** The properties that we provide dynamically. */
  override class func persistedProperties() -> [String] {
    return ["brimSize", "color", "createdAt", "updatedAt"]
  }
}