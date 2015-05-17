import XCTest
import Tailor
import TailorTesting

class CookieTests: TailorTestCase {
  var cookie = Cookie(key: "testCookie", value: "27")  
  //MARK: - Header String
  
  func testGetsHeaderStringForSimpleCookie() {
    assert(cookie.headerString, equals: "testCookie=27; Path=/", message: "has the cookie's key, value, and path")
  }
  
  func testGetsHeaderStringForCookieWithExpirationDate() {
    cookie.expiresAt = 1600.seconds.fromNow
    cookie.maxAge = 120
    let dateDescription = cookie.expiresAt!.format(TimeFormat.Cookie)
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
}
