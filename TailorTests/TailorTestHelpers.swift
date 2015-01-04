import Foundation

class TestApplication: Application {
  override class func extractArguments() -> [String] { return ["tailor.exit"] }
  required init(arguments: [String]? = nil) {
    super.init(arguments: arguments)
    self.rootPath = "./TailorTests/config"
  }
  
  override func openDatabaseConnection() -> DatabaseConnection {
    let config = self.configFromFile("database") as [String:String]
    return MysqlConnection(config: config)
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
  }
  
  override func configFromFile(file: String) -> NSDictionary {
    switch(file) {
    case "database":
      return [
        "host": "127.0.0.1",
        "username": "tailor",
        "password": "tailor",
        "database": "tailor_tests"
      ]
    case "sessions":
      return [
        "encryptionKey": "0FC7ECA7AADAD635DCC13A494F9A2EA8D8DAE366382CDB3620190F6F20817124"
      ]
    case "strings":
      return [
        "en": [
          "template.test": "Localized Text",
          "template.test_raw": "<b>Hello</b>",
          "record.shelf.attributes.store": "hat store",
          "controller.test.message": "Hello"
        ],
        "es": [
          "controller.test.message": "Hola"
        ]
      ]
    default:
      return [:]
    }
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
  dynamic var brimSize: NSNumber!
  dynamic var color: String!
  dynamic var shelfId: NSNumber!
  dynamic var owner: String!
  dynamic var createdAt: NSDate!
  dynamic var updatedAt: NSDate!
  
  override class func persistedProperties() -> [String] {
    return ["brimSize", "color", "shelfId", "createdAt", "updatedAt"]
  }
}

class Shelf : Record {
  dynamic var name: String!
  dynamic var storeId: NSNumber!
  
  override class func persistedProperties() -> [String] {
    return ["name", "storeId"]
  }
}

class Store : Record {
  dynamic var name: String!
  
  override class func persistedProperties() -> [String] {
    return ["name"]
  }
}
