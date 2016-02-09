import Tailor
import TailorTesting
import TailorSqlite
import XCTest
import Foundation

func prepareTestSuite() {
  Application.configuration.databaseDriver = { return SqliteConnection(path: "testing.sqlite") }
  CreateTestDatabaseAlteration.run()
}
extension TailorTestable {
	public func configure() {
    APPLICATION_ARGUMENTS = ("tailor.exit", [:])
    Application.configuration.databaseDriver = { return SqliteConnection(path: "testing.sqlite") }
    Application.configuration.sessionEncryptionKey = "0FC7ECA7AADAD635DCC13A494F9A2EA8D8DAE366382CDB3620190F6F20817124"
    Application.configuration.resourcePath = "./TestResources"
    //Application.configuration.userType = TestUser.self
    Application.configuration.projectName = "TailorTests"
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }
	}
}
extension NSObject {
	class func stubMethod(methodName: String, result: AnyObject?, @noescape body: Void->Void) {
		XCTFail("stubMethod not supported")
	}
	class func stubClassMethod(methodName: String, result: AnyObject?, @noescape body: Void->Void) {
		XCTFail("stubMethod not supported")
	}
}

public func NSStringFromClass(class: Any.Type) -> String {
	return ""
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


class StubbedTestCase {
  var failures = [(message: String, file: String, line: UInt)]()
  
  func XCTFail(message: String, file: StaticString, line: UInt) {
    self.failures.append((message: message, file: String(file), line: line))
  }
}