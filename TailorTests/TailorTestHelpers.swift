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
  var queries = [(String,[DatabaseValue])]()
  var response : [DatabaseConnection.Row] = []
  
  override func executeQuery(query: String, parameters bindParameters: [DatabaseValue]) -> [Row] {
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
  var brimSize: Int
  var color: String
  var shelfId: Int
  var owner: String?
  var createdAt: NSDate?
  var updatedAt: NSDate?
  
  
  init(brimSize: Int = 0, color: String = "", shelfId: Int = 0, owner: String? = nil, id: Int? = nil) {
    self.brimSize = brimSize
    self.color = color
    self.shelfId = shelfId
    self.owner = owner
    super.init(id: id)
  }
  
  override func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return [
      "brim_size": brimSize,
      "color": color,
      "shelf_id": shelfId,
      "created_at": createdAt,
      "updated_at": updatedAt,
    ]
  }
  
  override class func decode(databaseRow: [String:DatabaseValue]) -> Self? {
    if let brimSize = databaseRow["brim_size"]?.intValue,
      let color = databaseRow["color"]?.stringValue,
      let shelfId = databaseRow["shelf_id"]?.intValue {
        var result = self.init(
          brimSize: brimSize,
          color: color,
          shelfId: shelfId,
          id: databaseRow["id"]?.intValue
        )
        result.createdAt = databaseRow["created_at"]?.dateValue
        result.updatedAt = databaseRow["updated_at"]?.dateValue
        return result
    }
    else {
      return nil
    }
  }
}

class Shelf : Record {
  var name: String?
  var storeId: Int
  
  init(name: String?, storeId: Int = 0, id: Int? = nil) {
    self.name = name
    self.storeId = storeId
    super.init(id: id)
  }
  override func valuesToPersist() -> [String: DatabaseValueConvertible?] {
    return [
      "name": name,
      "store_id": storeId
    ]
  }
  
  override class func decode(databaseRow: [String:DatabaseValue]) -> Self? {
    if let name = databaseRow["name"]?.stringValue {
      var result = self.init(name: name, id: databaseRow["id"]?.intValue)
      result.storeId = databaseRow["store_id"]?.intValue ?? 0
      return result
    }
    else {
      return nil
    }
  }
}

class Store : Record {
  var name: String
  
  init(name: String, id: Int?=nil) {
    self.name = name
    super.init(id: id)
  }
  
  override func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return [
      "name": name
    ]
  }
  
  override class func decode(databaseRow: [String:DatabaseValue]) -> Self? {
    if let name = databaseRow["name"]?.stringValue,
      let id = databaseRow["id"]?.intValue {
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