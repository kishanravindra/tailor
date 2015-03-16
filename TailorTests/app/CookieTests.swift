import XCTest
import Tailor

class CookieTests: XCTestCase {
  var cookie = Cookie(key: "testCookie", value: "27")  
  //MARK: - Header String
  
  func testGetsHeaderStringForSimpleCookie() {
    XCTAssertEqual(cookie.headerString, "testCookie=27; Path=/", "has the cookie's key, value, and path")
  }
  
  func testGetsHeaderStringForCookieWithExpirationDate() {
    cookie.expiresAt = NSDate(timeIntervalSinceNow: 1600)
    cookie.maxAge = 120
    let dateDescription = COOKIE_DATE_FORMATTER.stringFromDate(cookie.expiresAt!)
    XCTAssertEqual(cookie.headerString, "testCookie=27; Path=/; Expires=" + dateDescription + "; Max-Age=120", "has the cookie's expiration date and age")
  }
  
  func testGetsHeaderStringForSecureCookie() {
    cookie.secureOnly = true
    XCTAssertEqual(cookie.headerString, "testCookie=27; Path=/; Secure", "has cookie with secure flag")
  }
  
  func testGetsHeaderStringForHttpOnlyCookie() {
    cookie.httpOnly = true
    XCTAssertEqual(cookie.headerString, "testCookie=27; Path=/; HttpOnly", "has cookie with HTTP-only flag")
  }
}
