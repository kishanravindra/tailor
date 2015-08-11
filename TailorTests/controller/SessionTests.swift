import XCTest
import Tailor
import TailorTesting

class SessionTests: TailorTestCase {
  let session: Session! = nil
  
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
      jsonData = try NSJSONSerialization.dataWithJSONObject(mergedData, options: [])
    }
    catch {
      jsonData = NSData()
    }
    let encryptor = AesEncryptor(key: key)
    let encryptedData = encryptor?.encrypt(jsonData) ?? NSData()
    let encryptedDataString = encryptedData.base64EncodedStringWithOptions([])
    return encryptedDataString
  }
  
  func createSession(cookieString: String) -> Session {
    return Session(request: Request(cookies: ["_session": cookieString]))
  }
  
  override func setUp() {
    super.setUp()
    Application.configuration.localization = { PropertyListLocalization(locale: $0) }
  }
  //MARK: - Creation
  
  func testInitializationWithValidSessionKeySetsData() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      flashData: ["notice": "Success"]
    )
    let request = Request(cookies: ["_session": string])
    let session = Session(request: request)
    
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
    let request = Request(cookies: ["_session": string], clientAddress: "0.0.0.0")
    let session = Session(request: request)
    XCTAssertTrue(session.isEmpty(), "has no data in session")
  }
  
  func testInitializationWithNoClientAddressInSessionDataLeavesSessionEmpty() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      clientAddress: nil
    )
    let request = Request(cookies: ["_session": string])
    let session = Session(request: request)
    assert(session.isEmpty())
  }
  
  func testInitalizationWithExpiredDateLeavesDataEmpty() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      expirationDate: 1.hour.ago
    )
    let request = Request(cookies: ["_session": string])
    let session = Session(request: request)
    XCTAssertTrue(session.isEmpty(), "has no data in session")
  }
  
  func testInitializationWithNoExpirationDateLeavesDataEmpty() {
    let string = createCookieString(
      ["name": "John", "userId": "5"],
      expirationDate: nil
    )
    let request = Request(cookies: ["_session": string])
    let session = Session(request: request)
    assert(session.isEmpty())
  }
  
  func testInitializationWithGarbageStringLeavesDataEmpty() {
    let request = Request(cookies: ["_session": "ABC-123"])
    let session = Session(request: request)
    XCTAssertTrue(session.isEmpty(), "has no data in session")
  }
  
  func testInitializationWithNoSessionCookieLeavesDataEmpty() {
    let request = Request()
    let session = Session(request: request)
    assert(session.isEmpty())
  }
  
  func testInitializationWithNonJsonDataInCookieLeavesSesssionEmpty() {
    let key = Application.configuration.sessionEncryptionKey
    let data = NSData(bytes: [1,2,3,4])
    let encryptedData = AesEncryptor(key: key)!.encrypt(data)
    let string = encryptedData.base64EncodedStringWithOptions([])
    let request = Request(cookies: ["_session": string])
    let session = Session(request: request)
    assert(session.isEmpty())
  }
  
  func testInitializationWithIntegerDataInCookieLeavesSesssionEmpty() {
    let key = Application.configuration.sessionEncryptionKey
    let data = "{\"a\":5}".dataUsingEncoding(NSUTF8StringEncoding)!
    let encryptedData = AesEncryptor(key: key)!.encrypt(data)
    let string = encryptedData.base64EncodedStringWithOptions([])
    let request = Request(cookies: ["_session": string])
    let session = Session(request: request)
    assert(session.isEmpty())
  }
  
  //MARK: - Serialization
  
  func testCookieStringWithNoChangesIsIdempotent() {
    let string = createCookieString(["name": "John", "userId": "5"])
    let request = Request(cookies: ["_session": string])
    let session = Session(request: request)
    let outputString = session.cookieString()
    assert(string, equals: outputString, message: "cookie string has not changed")
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
    let jsonObject : [String:String]
    do {
      jsonObject = try NSJSONSerialization.JSONObjectWithData(decodedData, options: []) as? [String : String] ?? [:]
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
    let string = cookieJar["_session"]
    XCTAssertNotNil(string, "sets cookie string")
    if string != nil { assert(string!, equals: session.cookieString(), message: "sets cookie string") }
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
