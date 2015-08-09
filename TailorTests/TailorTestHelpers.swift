import Foundation
import Tailor
import TailorTesting
import TailorSqlite

extension TailorTestCase {
  public dynamic func configure() {
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
    Application.configuration.databaseDriver = { return SqliteConnection(path: "testing.sqlite") }
    Application.configuration.sessionEncryptionKey = "0FC7ECA7AADAD635DCC13A494F9A2EA8D8DAE366382CDB3620190F6F20817124"
    Application.configuration.userType = TestUser.self
  }
}
final class TestConnection : DatabaseDriver {
  var timeZone: TimeZone
  var queries = [(String,[DatabaseValue])]()
  var response : [DatabaseConnection.Row] = []
  static var connectionCount = 0
  
  init(config: [String : String]) {
    timeZone = TimeZone.systemTimeZone()
    TestConnection.connectionCount += 1
  }
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
  
  func tables() -> [String:String] {
    return [:]
  }
}

struct Hat : Persistable, Equatable {
  let id: Int?
  var brimSize: Int
  var color: String
  var shelfId: Int?
  var owner: String?
  var createdAt: Timestamp?
  var updatedAt: Timestamp?
  static let query = Query<Hat>()
  
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
  
  init(databaseRow: DatabaseRow) throws {
    self.brimSize = try databaseRow.read("brim_size")
    self.color = try databaseRow.read("color")
    self.shelfId = try databaseRow.read("shelf_id")
    self.id = try databaseRow.read("id")
    self.createdAt = try databaseRow.read("created_at")
    self.updatedAt = try databaseRow.read("updated_at")
  }
}

struct Shelf : Persistable, Equatable {
  let id: Int?
  var name: String?
  var storeId: Int
  static let query = Query<Shelf>()
  
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
  
  init(databaseRow: DatabaseRow) throws {
    self.name = try databaseRow.read("name")
    self.id = try databaseRow.read("id")
    self.storeId = try databaseRow.read("store_id") ?? 0
    
    if databaseRow.data["throwError"] != nil {
      throw DatabaseError.GeneralError(message: "I was told to throw an error")
    }
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
  static let query = Query<Store>()
  
  func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return [
      "name": name
    ]
  }
  
  init(databaseRow: DatabaseRow) throws {
    self.name = try databaseRow.read("name")
    self.id = try databaseRow.read("id")
  }
}

@available(*, deprecated) extension Controller {
  convenience init() {
    self.init(request: Request(), actionName: "index", callback: {_ in })
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
  let id: Int?
  var emailAddress: String = ""
  var encryptedPassword: String = ""
  
  init() {
    id = nil
  }
  
  init(databaseRow: DatabaseRow) throws {
    self.id = try databaseRow.read("id")
    self.emailAddress = try databaseRow.read("email_address")
    self.encryptedPassword = try databaseRow.read("encrypted_password")
  }
  
  func valuesToPersist() -> [String : DatabaseValueConvertible?] {
    return ["email_address": emailAddress, "encrypted_password": encryptedPassword]
  }
  
  static let tableName = "users"
  static let query = Query<TestUser>()
}
  