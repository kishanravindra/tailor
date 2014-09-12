import Foundation

/**
  This class models a hat in our Haberdashery.
  */
class Hat : Record {
  //MARK: - Structure
  
  /** The size of the hat's brim. */
  var brimSize : Int!
  
  /** The color of the hat. */
  var color : String!
  
  /** The date when the record was created. */
  private(set) var createdAt : NSDate!
  
  /** The date when the record was last updated. */
  private(set) var updatedAt : NSDate!
  
  /** The name of the table that backs this class. */
  override class func tableName() -> String { return "hats" }
  
  /**
    This method initializes a hat with the columns from the database.
  
    :params: data   The columns from the database.
    */
  required init(data: [String:Any]) {
    self.brimSize = data["brim_size"] as? Int
    self.color = data["color"] as? String
    self.createdAt = data["created_at"] as? NSDate
    self.updatedAt = data["updated_at"] as? NSDate
    super.init(data: data)
  }
}