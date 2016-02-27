import XCTest
import Tailor
import TailorTesting

final class TestCookie: XCTestCase, TailorTestable {
  var cookie = Cookie(key: "testCookie", value: "27")
  
  var allTests: [(String, () throws -> Void)] { return [
    ("testGetsHeaderStringForSimpleCookie", testGetsHeaderStringForSimpleCookie),
    ("testGetsHeaderStringForCookieWithExpirationDate", testGetsHeaderStringForCookieWithExpirationDate),
    ("testGetsHeaderStringForSecureCookie", testGetsHeaderStringForSecureCookie),
    ("testGetsHeaderStringForHttpOnlyCookie", testGetsHeaderStringForHttpOnlyCookie),
    ("testCookiesAreEqualWithSameKeyAndValue", testCookiesAreEqualWithSameKeyAndValue),
    ("testCookiesAreUnequalWithDifferentKey", testCookiesAreUnequalWithDifferentKey),
    ("testCookiesAreUnequalWithDifferentValue", testCookiesAreUnequalWithDifferentValue),
    ("testCookiesAreUnequalWithDifferentChangedFlag", testCookiesAreUnequalWithDifferentChangedFlag),
    ("testCookiesAreUnequalWithDifferentDomain", testCookiesAreUnequalWithDifferentDomain),
    ("testCookiesAreUnequalWithDifferentExpiryTime", testCookiesAreUnequalWithDifferentExpiryTime),
    ("testCookiesAreUnequalWithDifferentHttpOnlyFlag", testCookiesAreUnequalWithDifferentHttpOnlyFlag),
    ("testCookiesAreUnequalWithDifferentMaxAge", testCookiesAreUnequalWithDifferentMaxAge),
    ("testCookiesAreUnequalWithDifferentPath", testCookiesAreUnequalWithDifferentPath),
    ("testCookiesAreUnequalWithDifferentSecureOnlyFlag", testCookiesAreUnequalWithDifferentSecureOnlyFlag),
  ]}

  func setUp() {
    setUpTestCase()
    cookie = Cookie(key: "testCookie", value: "27")
  }
  
  //MARK: - Header String
  
  func testGetsHeaderStringForSimpleCookie() {
    assert(cookie.headerString, equals: "testCookie=27; Path=/", message: "has the cookie's key, value, and path")
  }
  
  func testGetsHeaderStringForCookieWithExpirationDate() {
    cookie.expiresAt = 1600.seconds.fromNow
    cookie.maxAge = 120
    let dateDescription = cookie.expiresAt!.inTimeZone(TimeZone(name: "GMT")).format(TimeFormat.Cookie)
    assert(cookie.headerString, equals: "testCookie=27; Path=/; Expires=" + dateDescription + "; Max-Age=120", message: "has the cookie's expiration date and age")
  }
  
  func testGetsHeaderStringForSecureCookie() {
    cookie.secureOnly = true
    assert(cookie.headerString, equals: "testCookie=27; Path=/; Secure", message: "has cookie with secure flag")
  }
  
  func testGetsHeaderStringForHttpOnlyCookie() {
    cookie.httpOnly = true
    assert(cookie.headerString, equals: "testCookie=27; Path=/; HttpOnly", message: "has cookie with HTTP-only flag")
  }
  
  //MARK: - Equatable
  
  func testCookiesAreEqualWithSameKeyAndValue() {
    let cookie2 = Cookie(key: "testCookie", value: "27")
    assert(cookie, equals: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentKey() {
    let cookie2 = Cookie(key: "testCookie2", value: "27")
    assert(cookie, doesNotEqual: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentValue() {
    let cookie2 = Cookie(key: "testCookie", value: "28")
    assert(cookie, doesNotEqual: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentChangedFlag() {
    var cookie2 = Cookie(key: "testCookie", value: "27")
    cookie2.changed = true
    assert(cookie, doesNotEqual: cookie2)
    cookie.changed = true
    assert(cookie, equals: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentDomain() {
    var cookie2 = Cookie(key: "testCookie", value: "27")
    cookie2.domain = "tailorframe.work"
    assert(cookie, doesNotEqual: cookie2)
    cookie.domain = "tailorframe.work"
    assert(cookie, equals: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentExpiryTime() {
    var cookie2 = Cookie(key: "testCookie", value: "27")
    let timestamp = 30.minutes.fromNow
    cookie2.expiresAt = timestamp
    assert(cookie, doesNotEqual: cookie2)
    cookie.expiresAt = timestamp
    assert(cookie, equals: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentHttpOnlyFlag() {
    var cookie2 = Cookie(key: "testCookie", value: "27")
    cookie2.httpOnly = true
    assert(cookie, doesNotEqual: cookie2)
    cookie.httpOnly = true
    assert(cookie, equals: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentMaxAge() {
    var cookie2 = Cookie(key: "testCookie", value: "27")
    cookie2.maxAge = 3600
    assert(cookie, doesNotEqual: cookie2)
    cookie.maxAge = 3600
    assert(cookie, equals: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentPath() {
    var cookie2 = Cookie(key: "testCookie", value: "27")
    cookie2.path = "/hello"
    assert(cookie, doesNotEqual: cookie2)
    cookie.path = "/hello"
    assert(cookie, equals: cookie2)
  }
  
  func testCookiesAreUnequalWithDifferentSecureOnlyFlag() {
    var cookie2 = Cookie(key: "testCookie", value: "27")
    cookie2.secureOnly = true
    assert(cookie, doesNotEqual: cookie2)
    cookie.secureOnly = true
    assert(cookie, equals: cookie2)
  }
}
