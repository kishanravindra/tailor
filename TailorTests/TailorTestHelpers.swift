import Foundation
import Tailor
import TailorTesting

class TestApplication: Tailor.Application {
   required init() {
    super.init()
    self.configuration.addDictionary([
    "database": [
      "host": "127.0.0.1",
      "username": "tailor",
      "password": "tailor",
      "database": "tailor_tests"
    ],
    "sessions": [
      "encryptionKey": "0FC7ECA7AADAD635DCC13A494F9A2EA8D8DAE366382CDB3620190F6F20817124"
    ]])
  }
  
  override func openDatabaseConnection() -> DatabaseConnection {
    let config = self.configuration.child("database").toDictionary() as! [String: String]
    return MysqlConnection(config: config)
  }
  
  override func rootPath() -> String {
    return "TailorTests"
  }
  
  override func start() {
    super.start()
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS `hats`")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE `hats` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `color` varchar(255), `brim_size` int(11), shelf_id int(11), `created_at` timestamp, `updated_at` timestamp)")
    
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS `shelfs`")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE `shelfs` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `name` varchar(255), `store_id` int(11))")
    
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS `stores`")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE `stores` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `name` varchar(255))")
    
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS `users`")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE `users` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `email_address` varchar(255), `encrypted_password` varchar(255))")
    
    DatabaseConnection.sharedConnection().executeQuery("DROP TABLE IF EXISTS `tailor_translations`")
    DatabaseConnection.sharedConnection().executeQuery("CREATE TABLE `tailor_translations` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `translation_key` varchar(255), `locale` varchar(255), `translated_text` varchar(255))")
  }
}


class TestConnection : DatabaseConnection {
  var queries = [(String,[NSData])]()
  var response : [DatabaseConnection.Row] = []
  
  override func executeQuery(query: String, parameters bindParameters: [NSData]) -> [Row] {
    NSLog("Executing %@", query)
    queries.append((query, bindParameters))
    let temporaryResponse = response
    response = []
    return temporaryResponse
  }
  
  class func withTestConnection(block: (TestConnection)->()) {
    var dictionary = NSThread.currentThread().threadDictionary
    let oldConnection: AnyObject? = dictionary["databaseConnection"]
    let newConnection = TestConnection(config: [:])
    dictionary["databaseConnection"] = newConnection
    block(newConnection)
    dictionary["databaseConnection"] = oldConnection
  }
}

class Hat : Record {
  var brimSize: Int!
  dynamic var color: String!
  var shelfId: Int!
  dynamic var owner: String!
  dynamic var createdAt: NSDate!
  dynamic var updatedAt: NSDate!
  
  
  init(brimSize: Int! = nil, color: String! = nil, shelfId: Int! = nil, owner: String! = nil, id: Int! = nil) {
    self.brimSize = brimSize
    self.color = color
    self.shelfId = shelfId
    self.owner = owner
    super.init(id: id)
  }
  
  override func valuesToPersist() -> [String : NSData?] {
    return [
      "brim_size": brimSize == nil ? nil : String(brimSize).dataUsingEncoding(NSUTF8StringEncoding),
      "color": color?.dataUsingEncoding(NSUTF8StringEncoding),
      "shelf_id": shelfId == nil ? nil : String(shelfId).dataUsingEncoding(NSUTF8StringEncoding),
      "created_at": createdAt?.format("db", timeZone: DatabaseConnection.sharedConnection().timeZone)?.dataUsingEncoding(NSUTF8StringEncoding),
      "updated_at": updatedAt?.format("db", timeZone: DatabaseConnection.sharedConnection().timeZone)?.dataUsingEncoding(NSUTF8StringEncoding),
    ]
  }
  
  override class func decode(databaseRow: [String:Any]) -> Self? {
    var result = self.init(
      brimSize: databaseRow["brim_size"] as? Int,
      color: databaseRow["color"] as? String,
      shelfId: databaseRow["brim_size"] as? Int,
      id: databaseRow["id"] as? Int
    )
    result.createdAt = databaseRow["created_at"] as? NSDate
    result.updatedAt = databaseRow["updated_at"] as? NSDate
    return result
  }
}

class Shelf : Record {
  dynamic var name: String!
  var storeId: Int!
  
  init(name: String! = nil, storeId: Int! = nil, id: Int? = nil) {
    self.name = name
    self.storeId = storeId
    super.init(id: id)
  }
  override func valuesToPersist() -> [String: NSData?] {
    return [
      "name": self.name?.dataUsingEncoding(NSUTF8StringEncoding),
      "store_id": self.storeId == nil ? nil : String(self.storeId).dataUsingEncoding(NSUTF8StringEncoding)
    ]
  }
  
  override class func decode(databaseRow: [String:Any]) -> Self? {
    var result = self.init(id: databaseRow["id"] as? Int)
    result.name = databaseRow["name"] as? String
    result.storeId = databaseRow["store_id"] as? Int
    return result
  }
}

class Store : Record {
  dynamic var name: String
  
  init(name: String, id: Int?=nil) {
    self.name = name
    super.init(id: id)
  }
  
  override func valuesToPersist() -> [String : NSData?] {
    return [
      "name": name.dataUsingEncoding(NSUTF8StringEncoding)
    ]
  }
  
  override class func decode(databaseRow: [String:Any]) -> Self? {
    if let name = databaseRow["name"] as? String,
      let id = databaseRow["id"] as? Int {
      return self.init(name: name, id: id)
    }
    else {
      return nil
    }
  }
}

extension Controller {
  convenience init() {
    self.init(request: Request(), action: "index", callback: {_ in })
  }
}