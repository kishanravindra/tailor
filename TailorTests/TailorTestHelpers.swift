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
  
  override func openDatabaseConnection() -> DatabaseDriver {
    let config = self.configuration.child("database").toDictionary() as! [String: String]
    return MysqlConnection(config: config)
  }
  
  override func start() {
    super.start()
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `hats`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `hats` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `color` varchar(255), `brim_size` int(11), shelf_id int(11), `created_at` timestamp, `updated_at` timestamp)")
    
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `shelfs`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `shelfs` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `name` varchar(255), `store_id` int(11))")
    
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `stores`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `stores` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `name` varchar(255))")
    
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `users`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `users` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `email_address` varchar(255), `encrypted_password` varchar(255))")
    
    Application.sharedDatabaseConnection().executeQuery("DROP TABLE IF EXISTS `tailor_translations`")
    Application.sharedDatabaseConnection().executeQuery("CREATE TABLE `tailor_translations` ( `id` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, `translation_key` varchar(255), `locale` varchar(255), `translated_text` varchar(255))")
  }
}


final class TestConnection : DatabaseDriver {
  var timeZone: TimeZone
  var queries = [(String,[DatabaseValue])]()
  var response : [DatabaseConnection.Row] = []
  
  init(config: [String : String]) { timeZone = TimeZone.systemTimeZone() }
  func executeQuery(query: String, parameters bindParameters: [DatabaseValue]) -> [DatabaseRow] {
    NSLog("Executing %@", query)
    queries.append((query, bindParameters))
    let temporaryResponse = response
    response = []
    return temporaryResponse
  }
  
  class func withTestConnection(@noescape block: (TestConnection)->()) {
    let dictionary = NSThread.currentThread().threadDictionary
    let oldConnection: AnyObject? = dictionary["databaseConnection"]
    let newConnection = TestConnection(config: [:])
    dictionary["databaseConnection"] = newConnection
    block(newConnection)
    dictionary["databaseConnection"] = oldConnection
  }
}

struct Hat : Persistable {
  let id: Int?
  var brimSize: Int
  var color: String
  var shelfId: Int!
  var owner: String?
  var createdAt: Timestamp?
  var updatedAt: Timestamp?
  
  
  init(brimSize: Int = 0, color: String = "", shelfId: Int? = nil, owner: String? = nil, id: Int? = nil) {
    self.brimSize = brimSize
    self.color = color
    self.shelfId = shelfId
    self.owner = owner
    self.id = id
  }
  
  static var tableName: String { return "hats" }
  func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return [
      "brim_size": brimSize,
      "color": color,
      "shelf_id": shelfId,
      "created_at": createdAt,
      "updated_at": updatedAt,
    ]
  }
  
  init?(databaseRow: [String:DatabaseValue]){
    if let brimSize = databaseRow["brim_size"]?.intValue,
      let color = databaseRow["color"]?.stringValue {
        self.init(
          brimSize: brimSize,
          color: color,
          shelfId: databaseRow["id"]?.intValue,
          id: databaseRow["id"]?.intValue
        )
        createdAt = databaseRow["created_at"]?.timestampValue
        updatedAt = databaseRow["updated_at"]?.timestampValue
    }
    else {
      self.init()
      return nil
    }
  }
}

struct Shelf : Persistable {
  let id: Int?
  var name: String?
  var storeId: Int
  
  init(name: String?, storeId: Int = 0, id: Int? = nil) {
    self.name = name
    self.storeId = storeId
    self.id = id
  }
  
  static var tableName: String { return "shelfs" }
  
  func valuesToPersist() -> [String: DatabaseValueConvertible?] {
    return [
      "name": name,
      "store_id": storeId
    ]
  }
  
  init?(databaseRow: [String:DatabaseValue]) {
    self.name = databaseRow["name"]?.stringValue
    self.id = databaseRow["id"]?.intValue
    self.storeId = databaseRow["store_id"]?.intValue ?? 0
  }
}

struct Store : Persistable {
  let id: Int?
  var name: String
  
  init(name: String, id: Int?=nil) {
    self.name = name
    self.id = id
  }
  
  static var tableName: String { return "stores" }
  
  func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return [
      "name": name
    ]
  }
  
  init?(databaseRow: [String:DatabaseValue]) {
    if let name = databaseRow["name"]?.stringValue,
      let id = databaseRow["id"]?.intValue {
      self.init(name: name, id: id)
    }
    else {
      self.init(name: "")
      return nil
    }
  }
  
}

@available(*, deprecated) extension Controller {
  convenience init() {
    self.init(request: Request(), actionName: "index", callback: {_ in })
  }
}