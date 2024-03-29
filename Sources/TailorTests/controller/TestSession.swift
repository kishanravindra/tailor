import XCTest
import Tailor
import TailorTesting
import Foundation

final class TestSession: XCTestCase, TailorTestable {
  func createCookieString(data: [String:String] = [:], flashData: [String:String] = [:], clientAddress: String? = "0.0.0.0", expirationDate: Timestamp? = 1.hour.fromNow) -> String {
    var mergedData = data
    
    mergedData["clientAddress"] = clientAddress
    mergedData["expirationDate"] = expirationDate?.inTimeZone(TimeZone(name: "GMT")).format(TimeFormat.Cookie)
    for (key, value) in flashData {
      mergedData["_flash_\(key)"] = value
    }
    
    let key = Application.configuration.sessionEncryptionKey
    let jsonData: NSData
    do {
      jsonData = try mergedData.serialize.jsonData()
    }
    catch {
      jsonData = NSData()
    }
    let encryptor = AesEncryptor(key: key)
    let encryptedData = encryptor?.encrypt(jsonData) ?? NSData()
    let encryptedDataString = encryptedData.base64EncodedStringWithOptions([])
    return encryptedDataString
  }
  
  func parseCookieString(cookieString: String) -> [String:String] {
    let key = Application.configuration.sessionEncryptionKey
    let decryptor = AesEncryptor(key: key)
    let cookieData = NSData(base64EncodedString: cookieString, options: []) ?? NSData()
    let decodedData = decryptor?.decrypt(cookieData) ?? NSData()
    var jsonObject : [String:String] = [:]
    do {
      let dictionary = try NSJSONSerialization.JSONObjectWithData(decodedData, options: []) as? [String: Any] ?? [:]
      for (key, value) in dictionary {
        if let string = value as? String {
          jsonObject[key] = string
        }
      }
    }
    catch {
      jsonObject = [:]
    }
    return jsonObject
  }
  
  func createSession(cookieString: String) -> Session {
    return Session(cookieString: cookieString, clientAddress: "0.0.0.0")
  }
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testInitializationWithValidSessionKeySetsData", testInitializationWithValidSessionKeySetsData),
    ("testInitializationWithWrongClientAddressLeavesDataEmpty", testInitializationWithWrongClientAddressLeavesDataEmpty),
    ("testInitializationWithNoClientAddressInSessionDataLeavesSessionEmpty", testInitializationWithNoClientAddressInSessionDataLeavesSessionEmpty),
    ("testInitalizationWithExpiredDateLeavesDataEmpty", testInitalizationWithExpiredDateLeavesDataEmpty),
    ("testInitializationWithNoExpirationDateLeavesDataEmpty", testInitializationWithNoExpirationDateLeavesDataEmpty),
    //("testInitializationWithGarbageStringLeavesDataEmpty", testInitializationWithGarbageStringLeavesDataEmpty),
    ("testInitializationWithNoSessionCookieLeavesDataEmpty", testInitializationWithNoSessionCookieLeavesDataEmpty),
    ("testInitializationWithNonJsonDataInCookieLeavesSesssionEmpty", testInitializationWithNonJsonDataInCookieLeavesSesssionEmpty),
    ("testInitializationWithIntegerDataInCookieLeavesSesssionEmpty", testInitializationWithIntegerDataInCookieLeavesSesssionEmpty),
    ("testUserIsFetchedFromIdInSession", testUserIsFetchedFromIdInSession),
    ("testUserIsNilWithBadId", testUserIsNilWithBadId),
    ("testUserToNilWithNoId", testUserToNilWithNoId),
    ("testCookieStringWithNoChangesCanRecreateSession", testCookieStringWithNoChangesCanRecreateSession),
    ("testCookieStringWithDataChangesConveysChanges", testCookieStringWithDataChangesConveysChanges),
    ("testCookieStringWithFutureExpirationDateSetsNewExpirationDateBasedOnSessionLifetime", testCookieStringWithFutureExpirationDateSetsNewExpirationDateBasedOnSessionLifetime),
    ("testCookieStringWithFlashParamsConveysOnlyNewParams", testCookieStringWithFlashParamsConveysOnlyNewParams),
    ("testCookieStringIsAesEncoded", testCookieStringIsAesEncoded),
    ("testCookieStringWithoutEncryptorIsEmptyString", testCookieStringWithoutEncryptorIsEmptyString),
    ("testStoreInCookiesPutsCookieStringInFlash", testStoreInCookiesPutsCookieStringInFlash),
    ("testSetFlashMethodDoesNotMakeValueAvailableImmediately", testSetFlashMethodDoesNotMakeValueAvailableImmediately),
    ("testSetFlashMethodMakesValueAvailableImmediatelyWhenFlagIsSet", testSetFlashMethodMakesValueAvailableImmediatelyWhenFlagIsSet),
  ]}

  
  func setUp() {
    setUpTestCase()
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }
  }
  
  //MARK: - Creation
  
  func testInitializationWithValidSessionKeySetsData() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      flashData: ["notice": "Success"]
    )
    let session = Session(cookieString: string, clientAddress: "0.0.0.0")
    
    let name = session["name"]
    XCTAssertNotNil(name, "has the name in the data")
    if name != nil {
      assert(name!, equals: "John", message: "has the name in the data")
    }
    
    let userId = session["userId"]
    XCTAssertNotNil(userId, "has the user id in the data")
    if userId != nil {
      assert(userId!, equals: "5", message: "has the user id in the data")
    }
    
    XCTAssertNil(session["_flash_notice"], "does not have a flash notice in the main data")
    
    let notice = session.flash("notice")
    XCTAssertNotNil(notice, "has the flash notice")
    if notice != nil {
      assert(notice!, equals: "Success", message: "has the flash notice")
    }
  }
  
  func testInitializationWithWrongClientAddressLeavesDataEmpty() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      clientAddress: "1.1.1.1"
    )
    let session = Session(cookieString: string, clientAddress: "0.0.0.0")
    XCTAssertTrue(session.isEmpty(), "has no data in session")
  }
  
  func testInitializationWithNoClientAddressInSessionDataLeavesSessionEmpty() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      clientAddress: nil
    )
    let session = Session(cookieString: string, clientAddress: "0.0.0.0")
    assert(session.isEmpty())
  }
  
  func testInitalizationWithExpiredDateLeavesDataEmpty() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      expirationDate: 1.hour.ago
    )
    let session = Session(cookieString: string, clientAddress: "0.0.0.0")
    assert(session.isEmpty(), message: "has no data in session")
  }
  
  func testInitializationWithNoExpirationDateLeavesDataEmpty() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      expirationDate: nil
    )
    let session = Session(cookieString: string, clientAddress: "0.0.0.0")
    assert(session.isEmpty())
  }
  
  func testInitializationWithGarbageStringLeavesDataEmpty() {
    let session = Session(cookieString: "ABC-123", clientAddress: "0.0.0.0")
    assert(session.isEmpty(), message: "has no data in session")
  }
  
  func testInitializationWithNoSessionCookieLeavesDataEmpty() {
    let session = Session(cookieString: "", clientAddress: "0.0.0.0")
    assert(session.isEmpty())
  }
  
  func testInitializationWithNonJsonDataInCookieLeavesSesssionEmpty() {
    let key = Application.configuration.sessionEncryptionKey
    let data = NSData(bytes: [1,2,3,4])
    let encryptedData = AesEncryptor(key: key)!.encrypt(data)
    let string = encryptedData.base64EncodedStringWithOptions([])
    let session = Session(cookieString: string, clientAddress: "0.0.0.0")
    assert(session.isEmpty())
  }
  
  func testInitializationWithIntegerDataInCookieLeavesSesssionEmpty() {
    let key = Application.configuration.sessionEncryptionKey
    let data = NSData(bytes: "{\"a\":5}".utf8)
    let encryptedData = AesEncryptor(key: key)!.encrypt(data)
    let string = encryptedData.base64EncodedStringWithOptions([])
    let session = Session(cookieString: string, clientAddress: "0.0.0.0")
    assert(session.isEmpty())
  }
  
  //MARK: - Session Info
  
  
  
  func testUserIsFetchedFromIdInSession() {
    var user = TestUser()
    user.emailAddress = "test@test.com"
    user.password = "test"
    user = user.save()!
    let session = Request(sessionData: ["userId": String(user.id)]).session
    assert(session.user?.id, equals: user.id, message: "sets user to the one with the id given")
  }
  
  func testUserIsNilWithBadId() {
    var user = TestUser()
    user.emailAddress = "test@test.com"
    user.password = "test"
    user = user.save()!
    let session = Request(sessionData: ["userId": String(user.id + 1)]).session
    assert(isNil: session.user, message: "sets user to nil")
  }
  
  func testUserToNilWithNoId() {
    var user = TestUser()
    user.emailAddress = "test@test.com"
    user.password = "test"
    user.save()
    let session = Request().session
    assert(isNil: session.user, message: "sets user to nil")
  }
  
  
  //MARK: - Serialization
  
  func testCookieStringWithNoChangesCanRecreateSession() {
    let string = createCookieString(["name": "John", "userId": "5"])
    let session = Session(cookieString: string, clientAddress: "0.0.0.0")
    let outputString = session.cookieString()
    let session2 = Session(cookieString: outputString, clientAddress: "0.0.0.0")
    assert(session2["name"], equals: "John")
    assert(session2["userId"], equals: "5")
  }
  
  func testCookieStringWithDataChangesConveysChanges() {
    var session = createSession(createCookieString(["name": "Joan"]))
    session["name"] = "Jane"
    session["userId"] = "1"
    let session2 = createSession(session.cookieString())
    
    let name = session2["name"]
    XCTAssertNotNil(name, "carries a changed session param")
    if name != nil { assert(name!, equals: "Jane", message: "carries a changed session param") }
    
    let userId = session2["userId"]
    XCTAssertNotNil(userId, "carries a new session param")
    if userId != nil { assert(userId!, equals: "1", message: "carries a new session param") }
  }
  
  func testCookieStringWithFutureExpirationDateSetsNewExpirationDateBasedOnSessionLifetime() {
    let session = createSession(createCookieString(["name": "Joan"], expirationDate: 30.minutes.fromNow))
    let date = parseCookieString(session.cookieString())["expirationDate"]
    let futureTimestamp = 1.hour.fromNow.inTimeZone(TimeZone(name: "GMT")).format(TimeFormat.Cookie)
    assert(date, equals: futureTimestamp)
  }

  
  func testCookieStringWithFlashParamsConveysOnlyNewParams() {
    var session = createSession(createCookieString(flashData: ["notice": "Success"]))
    session.setFlash("notice", "More Success", currentPage: true)
    session.setFlash("error", "Error")
    let session2 = createSession(session.cookieString())
    
    XCTAssertNil(session2.flash("notice"), "does not carry an old session param")
    let error = session2.flash("error")
    XCTAssertNotNil(error, "carries a new flash message")
    if error != nil { assert(error!, equals: "Error", message: "carries a new flash message") }
  }
  
  func testCookieStringIsAesEncoded() {
    var session = createSession(createCookieString(["name": "Joan"]))
    session.setFlash("notice", "Success")
    let string = session.cookieString()
    let key = Application.configuration.sessionEncryptionKey
    let decryptor = AesEncryptor(key: key)
    let cookieData = NSData(base64EncodedString: string, options: []) ?? NSData()
    XCTAssertNotEqual(cookieData.length, 0, "can base-64 decode the cookie data")
    let decodedData = decryptor?.decrypt(cookieData) ?? NSData()
    XCTAssertNotEqual(decodedData.length, 0, "can decrypt the cookie data with the application key")
    let jsonObject : [String:Any]
    do {
      jsonObject = try NSJSONSerialization.JSONObjectWithData(decodedData, options: []) as? [String : Any] ?? [:]
    }
    catch {
      jsonObject = [:]
    }
    XCTAssertNotNil(jsonObject, "can get JSON object back")
    let keys = jsonObject.keys.sort()
    assert(keys, equals: ["_flash_notice", "clientAddress", "expirationDate", "name"], message: "has the expected keys in the flash")
  }
  
  func testCookieStringWithoutEncryptorIsEmptyString() {
    Application.configuration.sessionEncryptionKey = ""
    let session = createSession(createCookieString(["name": "Joan"]))
    assert(session.cookieString(), equals: "")
  }
  
  func testStoreInCookiesPutsCookieStringInFlash() {
    let session = createSession(createCookieString())
    var cookieJar = CookieJar()
    session.storeInCookies(&cookieJar)
    assert(isNotNil: cookieJar["_session"], message: "creates a _session cookie")
  }
  
  //MARK: - Flash
  
  func testSetFlashMethodDoesNotMakeValueAvailableImmediately() {
    var session = createSession(createCookieString())
    session.setFlash("notice", "Success")
    XCTAssertNil(session.flash("notice"), "does not make flash message available")
  }
  
  func testSetFlashMethodMakesValueAvailableImmediatelyWhenFlagIsSet() {
    var session = createSession(createCookieString())
    session.setFlash("notice", "Success", currentPage: true)
    let notice = session.flash("notice")
    XCTAssertNotNil(notice, "makes flash message available")
    if notice != nil { assert(notice!, equals: "Success", message: "makes flash message available") }
  }
}
