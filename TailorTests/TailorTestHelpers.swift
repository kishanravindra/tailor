import Foundation
import Tailor
import TailorTesting
import TailorSqlite

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
  
  func tables() -> [String:String] {
    return [:]
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
          shelfId: databaseRow["shelf_id"]?.intValue,
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

extension NSObject {
  class func stubMethod<T: AnyObject>(name: String, result: T, @noescape block: Void -> Void) {
    let method = class_getInstanceMethod(self, Selector(name))
    let oldImplementation = method_getImplementation(method)
    let implementationBlock: @convention(block) (AnyObject)->AnyObject = {
      _ in
      return result
    }

    let newImplementation = imp_implementationWithBlock(unsafeBitCast(implementationBlock, AnyObject.self))
    method_setImplementation(method, newImplementation)
    block()
    method_setImplementation(method, oldImplementation)
  }
}