import XCTest
import Tailor

class CookieJarTests: XCTestCase {
  var cookieJar = CookieJar()
  
  //MARK: - Modifying Cookies
  
  func testSetCookieCreatesNewCookie() {
    cookieJar.setCookie("testKey", "testValue", path: "/path", domain: "mydomain.com")
    let cookie = cookieJar.cookies[0]
    XCTAssertEqual(cookie.key, "testKey", "sets the cookie key")
    XCTAssertEqual(cookie.value, "testValue", "sets the cookie value")
    XCTAssertEqual(cookie.path, "/path", "sets the cookie path")
    XCTAssertNotNil(cookie.domain)
    XCTAssertEqual(cookie.domain!, "mydomain.com", "sets the cookie domain")
    XCTAssertTrue(cookie.changed, "flags the cookie as changed")
  }
  
  func testSetCookieUpdatesExistingCookie() {
    cookieJar.setCookie("key1", "value1")
    cookieJar.setCookie("key2", "value2")
    cookieJar.setCookie("key2", "value3", path: "/path")
    XCTAssertEqual(cookieJar.cookies.count, 2, "does not create another cookie")
    let cookie1 = cookieJar.cookies[0]
    let cookie2 = cookieJar.cookies[1]
    XCTAssertEqual(cookie1.value, "value1", "does not modify value for first cookie")
    XCTAssertEqual(cookie2.value, "value3", "modifies value for second cookie")
    XCTAssertEqual(cookie2.path, "/path", "modifies path for second cookie")
  }
  
  func testAddHeaderStringCreatesCookies() {
    let headerString = "key1=value1; key2=value2"
    cookieJar.addHeaderString(headerString)
    
    XCTAssertEqual(cookieJar.cookies.count, 2, "creates one cookie for each assignment")
    
    let cookie1 = cookieJar.cookies[0]
    let cookie2 = cookieJar.cookies[1]
    XCTAssertEqual(cookie1.key, "key1", "sets key for first cookie")
    XCTAssertEqual(cookie1.value, "value1", "sets value for first cookie")
    XCTAssertFalse(cookie1.changed, "flags cookie as not changed")
    
    XCTAssertEqual(cookie2.key, "key2", "sets key for second cookie")
    XCTAssertEqual(cookie2.value, "value2", "sets value for second cookie")
    XCTAssertFalse(cookie2.changed, "flags cookie as not changed")
  }
  
  //MARK: - Access
  
  func testSubscriptGetsCookieValue() {
    cookieJar.setCookie("key1", "value1")
    cookieJar.setCookie("key2", "value2")
    XCTAssertNotNil(cookieJar["key1"], "can get value for first key")
    XCTAssertEqual(cookieJar["key1"]!, "value1", "gets value for first cookie")
    XCTAssertNotNil(cookieJar["key2"], "can get value for second key")
    XCTAssertEqual(cookieJar["key2"]!, "value2", "gets value for second cookie")
    XCTAssertNil(cookieJar["key3"], "cannot get value for invalid key")
  }
  
  func testSubscriptSetsCookieValue() {
    cookieJar["key1"] = "value1"
    XCTAssertEqual(cookieJar.cookies.count, 1, "creates the cookie")
    let cookie = cookieJar.cookies[0]
    XCTAssertEqual(cookie.key, "key1", "sets cookie key")
    XCTAssertEqual(cookie.value, "value1", "sets cookie value")
  }
  
  func testCookieDictionaryGetsHashOfValues() {
    cookieJar.setCookie("key1", "value1")
    cookieJar.setCookie("key2", "value2")
    XCTAssertEqual(cookieJar.cookieDictionary(), ["key1": "value1", "key2": "value2"], "has hash of cookie keys and values")
  }
  
  //MARK: - Serialization
  
  func setHeaderStringIncludesChanges() {
    cookieJar.addHeaderString("key1=value1; key2=value2")
    cookieJar.setCookie("key2", "value4", path: "/path")
    cookieJar.setCookie("key3", "value3", maxAge: 160, secureOnly: true)
    let cookie2 = cookieJar.cookies[1]
    let cookie3 = cookieJar.cookies[2]
    let headerString = cookieJar.headerStringForChanges
    XCTAssertEqual(headerString, "Set-Cookie: \(cookie2.headerString)\nSet-Cookie: \(cookie3.headerString)\n", "header string combines header strings for changed cookies")
  }
  
  //MARK: Formatting
  
  func testCookieDateFormatterUsesCookieFormat() {
    let oldTimeZone = COOKIE_DATE_FORMATTER.timeZone
    COOKIE_DATE_FORMATTER.timeZone = NSTimeZone(name: "UTC")
    let date = NSDate(timeIntervalSince1970: 1418729233)
    let formatted = COOKIE_DATE_FORMATTER.stringFromDate(date)
    XCTAssertEqual(formatted, "Tue, 16 Dec 2014 11:27:13 GMT", "formats string using cookie date format")
    COOKIE_DATE_FORMATTER.timeZone = oldTimeZone
  }
}
