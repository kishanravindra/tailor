import XCTest
import Tailor
import TailorTesting

final class TestCookieJar: XCTestCase, TailorTestable {
  var cookieJar = CookieJar()

  var allTests: [(String, () throws -> Void)] { return [
    ("testSetCookieCreatesNewCookie", testSetCookieCreatesNewCookie),
    ("testSetCookieUpdatesExistingCookie", testSetCookieUpdatesExistingCookie),
    ("testAddHeaderStringCreatesCookies", testAddHeaderStringCreatesCookies),
    ("testSubscriptGetsCookieValue", testSubscriptGetsCookieValue),
    ("testSubscriptSetsCookieValue", testSubscriptSetsCookieValue),
    ("testSubscriptWithNilSetsBlankValue", testSubscriptWithNilSetsBlankValue),
    ("testCookieDictionaryGetsHashOfValues", testCookieDictionaryGetsHashOfValues),
    ("testCopyDoesNotShareChanges", testCopyDoesNotShareChanges),
    ("testHeaderStringWithOneChangeHasNewline", testHeaderStringWithOneChangeHasNewline),
    ("testHeaderStringWithNoChangeIsEmpty", testHeaderStringWithNoChangeIsEmpty),
    ("testCookieJarsAreEqualWithSameCookies", testCookieJarsAreEqualWithSameCookies),
    ("testCookieJarsAreUnequalWithDifferentCookieValues", testCookieJarsAreUnequalWithDifferentCookieValues),
    ("testCookieJarsAreEqualWithSameCookiesInDifferentOrder", testCookieJarsAreEqualWithSameCookiesInDifferentOrder),
  ]}
  
  func setUp() {
    setUpTestCase()
    cookieJar = CookieJar()
  }
  
  //MARK: - Modifying Cookies
  
  func testSetCookieCreatesNewCookie() {
    cookieJar.setCookie("testKey", "testValue", path: "/path", domain: "mydomain.com")
    let cookie = cookieJar.cookies[0]
    self.assert(cookie.key, equals: "testKey", message: "sets the cookie key")
    self.assert(cookie.value, equals: "testValue", message: "sets the cookie value")
    self.assert(cookie.path, equals: "/path", message: "sets the cookie path")
    self.assert(cookie.domain, equals: "mydomain.com", message: "sets the cookie domain")
    XCTAssertTrue(cookie.changed, "flags the cookie as changed")
  }
  
  func testSetCookieUpdatesExistingCookie() {
    cookieJar.setCookie("key1", "value1")
    cookieJar.setCookie("key2", "value2")
    cookieJar.setCookie("key2", "value3", path: "/path")
    assert(cookieJar.cookies.count, equals: 2, message: "does not create another cookie")
    let cookie1 = cookieJar.cookies[0]
    let cookie2 = cookieJar.cookies[1]
    assert(cookie1.value, equals: "value1", message: "does not modify value for first cookie")
    assert(cookie2.value, equals: "value3", message: "modifies value for second cookie")
    assert(cookie2.path, equals: "/path", message: "modifies path for second cookie")
  }
  
  func testAddHeaderStringCreatesCookies() {
    let headerString = "key1=value1; key2=value2"
    cookieJar.addHeaderString(headerString)
    
    assert(cookieJar.cookies.count, equals: 2, message: "creates one cookie for each assignment")
    
    let cookie1 = cookieJar.cookies[0]
    let cookie2 = cookieJar.cookies[1]
    assert(cookie1.key, equals: "key1", message: "sets key for first cookie")
    assert(cookie1.value, equals: "value1", message: "sets value for first cookie")
    XCTAssertFalse(cookie1.changed, "flags cookie as not changed")
    
    assert(cookie2.key, equals: "key2", message: "sets key for second cookie")
    assert(cookie2.value, equals: "value2", message: "sets value for second cookie")
    XCTAssertFalse(cookie2.changed, "flags cookie as not changed")
  }
  
  //MARK: - Access
  
  func testSubscriptGetsCookieValue() {
    cookieJar.setCookie("key1", "value1")
    cookieJar.setCookie("key2", "value2")
    assert(cookieJar["key1"], equals: "value1", message: "gets value for first cookie")
    XCTAssertNil(cookieJar["key3"], "cannot get value for invalid key")
  }
  
  func testSubscriptSetsCookieValue() {
    cookieJar["key1"] = "value1"
    assert(cookieJar.cookies.count, equals: 1, message: "creates the cookie")
    let cookie = cookieJar.cookies[0]
    assert(cookie.key, equals: "key1", message: "sets cookie key")
    assert(cookie.value, equals: "value1", message: "sets cookie value")
  }
  
  func testSubscriptWithNilSetsBlankValue() {
    cookieJar["key1"] = nil
    assert(cookieJar.cookies.count, equals: 1, message: "creates the cookie")
    let cookie = cookieJar.cookies[0]
    assert(cookie.key, equals: "key1", message: "sets cookie key")
    assert(cookie.value, equals: "", message: "sets cookie value")
  }
  
  func testCookieDictionaryGetsHashOfValues() {
    cookieJar.setCookie("key1", "value1")
    cookieJar.setCookie("key2", "value2")
    assert(cookieJar.cookieDictionary(), equals: ["key1": "value1", "key2": "value2"], message: "has hash of cookie keys and values")
  }
  
  func testCopyDoesNotShareChanges() {
    let jar2 = cookieJar
    cookieJar["key1"] = "value1"
    assert(isNotNil: cookieJar["key1"])
    assert(isNil: jar2["key1"])
  }
  
  //MARK: - Serialization
  
  func setHeaderStringIncludesChanges() {
    cookieJar.addHeaderString("key1=value1; key2=value2")
    cookieJar.setCookie("key2", "value4", path: "/path")
    cookieJar.setCookie("key3", "value3", maxAge: 160, secureOnly: true)
    let cookie2 = cookieJar.cookies[1]
    let cookie3 = cookieJar.cookies[2]
    let headerString = cookieJar.headerStringForChanges
    assert(headerString, equals: "Set-Cookie: \(cookie2.headerString)\r\nSet-Cookie: \(cookie3.headerString)\n", message: "header string combines header strings for changed cookies")
  }
  
  func testHeaderStringWithOneChangeHasNewline() {
    cookieJar.addHeaderString("key1=value1; key2=value2")
    cookieJar.setCookie("key2", "value4", path: "/path")
    let cookie2 = cookieJar.cookies[1]
    let headerString = cookieJar.headerStringForChanges
    assert(headerString, equals: "Set-Cookie: \(cookie2.headerString)\r\n", message: "header string has header string for changed cookie with newline")
  }
  
  func testHeaderStringWithNoChangeIsEmpty() {
    cookieJar.addHeaderString("key1=value1; key2=value2")
    let headerString = cookieJar.headerStringForChanges
    assert(headerString, equals: "")
  }
  
  //MARK: - Comparison
  
  func testCookieJarsAreEqualWithSameCookies() {
    var cookieJar2 = CookieJar()
    cookieJar.setCookie("test1", "value1")
    cookieJar.setCookie("test2", "value2")
    cookieJar2.setCookie("test1", "value1")
    cookieJar2.setCookie("test2", "value2")
    assert(cookieJar, equals: cookieJar2)
  }
  
  func testCookieJarsAreUnequalWithDifferentCookieValues() {
    var cookieJar2 = CookieJar()
    cookieJar.setCookie("test1", "value1")
    cookieJar.setCookie("test2", "value2")
    cookieJar2.setCookie("test1", "value2")
    cookieJar2.setCookie("test2", "value3")
    assert(cookieJar, doesNotEqual: cookieJar2)
  }
  
  func testCookieJarsAreEqualWithSameCookiesInDifferentOrder() {
    var cookieJar2 = CookieJar()
    cookieJar.setCookie("test1", "value1")
    cookieJar.setCookie("test2", "value2")
    cookieJar2.setCookie("test2", "value2")
    cookieJar2.setCookie("test1", "value1")
    assert(cookieJar, equals: cookieJar2)
  }
}
