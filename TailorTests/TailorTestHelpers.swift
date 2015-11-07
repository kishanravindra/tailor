import Foundation
import Tailor
import TailorTesting
import TailorSqlite

extension TailorTestable {
  public func configure() {
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
    Application.configuration.databaseDriver = { return SqliteConnection(path: "testing.sqlite") }
    Application.configuration.sessionEncryptionKey = "0FC7ECA7AADAD635DCC13A494F9A2EA8D8DAE366382CDB3620190F6F20817124"
    Application.configuration.userType = TestUser.self
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }
  }
}
final class TestConnection : DatabaseDriver {
  var timeZone: TimeZone
  var queries = [(String,[SerializableValue])]()
  var response : [DatabaseRow] = []
  static var connectionCount = 0
  
  init(config: [String : String]) {
    timeZone = TimeZone.systemTimeZone()
    TestConnection.connectionCount += 1
  }
  func executeQuery(query: String, parameters bindParameters: [SerializableValue]) -> [DatabaseRow] {
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
  
  func tables() -> [String:String] {
    return [:]
  }
}

struct Hat : Persistable, Equatable {
  let id: UInt
  var brimSize: Int
  var color: String
  var shelfId: UInt?
  var owner: String?
  var createdAt: Timestamp?
  var updatedAt: Timestamp?
  static let query = Query<Hat>()
  
  init(brimSize: Int = 0, color: String = "", shelfId: UInt? = nil, owner: String? = nil, id: UInt = 0) {
    self.brimSize = brimSize
    self.color = color
    self.shelfId = shelfId
    self.owner = owner
    self.id = id
  }
  
  func valuesToPersist() -> [String : SerializationEncodable?] {
    return [
      "brim_size": brimSize,
      "color": color,
      "shelf_id": shelfId,
      "created_at": createdAt,
      "updated_at": updatedAt,
    ]
  }
  
  init(deserialize values: SerializableValue) throws {
    self.brimSize = try values.read("brim_size")
    self.color = try values.read("color")
    self.shelfId = try values.read("shelf_id")
    self.id = try values.read("id")
    self.createdAt = try values.read("created_at")
    self.updatedAt = try values.read("updated_at")
  }
}

struct Shelf : Persistable, Equatable {
  let id: UInt
  var name: String?
  var storeId: Int
  static let query = Query<Shelf>()
  
  init(name: String?, storeId: Int = 0, id: UInt = 0) {
    self.name = name
    self.storeId = storeId
    self.id = id
  }
  
  func valuesToPersist() -> [String: SerializationEncodable?] {
    return [
      "name": name,
      "store_id": storeId
    ]
  }
  
  init(deserialize values: SerializableValue) throws {
    self.name = try values.read("name")
    self.id = try values.read("id")
    self.storeId = try values.read("store_id") ?? 0
    
    let error = try? values.read("throwError") as Bool
    if error != nil {
      throw SerializationParsingError.MissingField(field: "throwError")
    }
  }
}

struct Store : Persistable {
  let id: UInt
  var name: String
  
  init(name: String, id: UInt=0) {
    self.name = name
    self.id = id
  }
  
  static let query = Query<Store>()
  
  func valuesToPersist() -> [String : SerializationEncodable?] {
    return [
      "name": name
    ]
  }
  
  init(deserialize values: SerializableValue) throws {
    self.name = try values.read("name")
    self.id = try values.read("id")
  }
}

extension NSObject {
  class func stubClassMethod<T: AnyObject>(name: String, result: T?, @noescape block: Void -> Void) {
    let method = class_getClassMethod(self, Selector(name))
    let oldImplementation = method_getImplementation(method)
    let implementationBlock: @convention(block) (AnyObject)->AnyObject? = {
      _ in
      return result
    }
    
    let newImplementation = imp_implementationWithBlock(unsafeBitCast(implementationBlock, AnyObject.self))
    method_setImplementation(method, newImplementation)
    block()
    method_setImplementation(method, oldImplementation)
  }
  
  class func stubMethod<T: AnyObject>(name: String, result: T?, @noescape block: Void -> Void) {
    let method = class_getInstanceMethod(self, Selector(name))
    let oldImplementation = method_getImplementation(method)
    let implementationBlock: @convention(block) (AnyObject)->AnyObject? = {
      _ in
      return result
    }

    let newImplementation = imp_implementationWithBlock(unsafeBitCast(implementationBlock, AnyObject.self))
    method_setImplementation(method, newImplementation)
    block()
    method_setImplementation(method, oldImplementation)
  }
}


struct TestUser: UserType, Equatable {
  let id: UInt
  var emailAddress: String = ""
  var encryptedPassword: String = ""
  
  init() {
    id = 0
    emailAddress = "test@test.com"
    encryptedPassword = "Foo"
  }
  
  init(deserialize values: SerializableValue) throws {
    NSLog("Building user: %@", String(values))
    self.id = try values.read("id")
    self.emailAddress = try values.read("email_address")
    self.encryptedPassword = try values.read("encrypted_password")
  }
  
  func valuesToPersist() -> [String : SerializationEncodable?] {
    return ["email_address": emailAddress, "encrypted_password": encryptedPassword]
  }
  
  static let tableName = "users"
  static let query = Query<TestUser>()
}


struct TopHat: Persistable {
  let id: UInt
  init(deserialize values: SerializableValue) throws {
    self.id = try values.read("id")
  }
  func valuesToPersist() -> [String : SerializationEncodable?] {
    return [:]
  }
}

  