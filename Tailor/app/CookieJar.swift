import Foundation

/**
  This class stories a set of cookies for a request.
  */
public class CookieJar {
  /** The cookies in the jar. */
  public private(set) var cookies: [Cookie] = []
  
  /**
    This method creates a cookie jar.
    */
  public init() {
  }
  
  //MARK: - Modifying Cookies
  
  /**
    This method changes a value for a cookie.
  
    :param: key             The identifier for the cookie.
    :param: value           The new value for the cookie.
    :param: path            The path for the pages that can access this cookie.
                            If this is not provided, all pages will be able to
                            access it.
    :param: expiresAt       The time when the cookie will expire. If this is
                            not provided, it will expire at the end of the
                            browser session.
    :param: maxAge          The number of seconds before the cookie should
                            expire.
    :param: domain          The domain that can see the cookie. If this is not
                            provided, the cookie will be visible to the domain
                            of the request, as well as its subdomains.
    :param: secureOnly      Whether the cookie should only be sent over secure
                            requests.
    :param: httpOnly        Whether the cookie should only be sent over
                            HTTP/HTTPS requests.
    */
  public func setCookie(key: String, _ value: String, path: String = "/",
    expiresAt: Timestamp? = nil, maxAge: Int? = nil, domain: String? = nil,
    secureOnly: Bool = false, httpOnly: Bool = false) {
      var cookie = Cookie(key: key, value: value)
      cookie.value = value
      cookie.path = path
      cookie.expiresAt = expiresAt
      cookie.maxAge = maxAge
      cookie.domain = domain
      cookie.secureOnly = secureOnly
      cookie.httpOnly = httpOnly
      cookie.changed = true
      for (index,existingCookie) in enumerate(self.cookies) {
        if existingCookie.key == key {
          self.cookies[index] = cookie
          return
        }
      }
      self.cookies.append(cookie)
  }
  
  /**
    This method adds a cookie from a cookie header string.

    This can contain several cookies in the format key=value, separated by a
    semicolon and a space.
    
    :param: string    The header string with the cookies.
    */
  public func addHeaderString(string: String) {
    for component in string.componentsSeparatedByString("; ") {
      let equalSignRange = component.rangeOfString("=", options: nil, range: nil, locale: nil)
      if equalSignRange != nil {
        let key = component.substringToIndex(equalSignRange!.startIndex)
        let value = component.substringFromIndex(equalSignRange!.endIndex)
        self.cookies.append(Cookie(key: key, value: value))
      }
    }
  }
  
  //MARK: - Access
  
  /**
    This method gets the value for a cookie in this jar.

    :param: key     The identifier for the cookie.
    :return:        The value, if we found one.
    */
  public subscript(key: String) -> String? {
    get {
      for cookie in self.cookies {
        if cookie.key == key {
          return cookie.value
        }
      }
      return nil
    }
    set {
      self.setCookie(key, newValue ?? "")
    }
  }
  
  /**
    This method gets a dictionary mapping cookie keys to values.

    :returns:   The mapping.
    */
  public func cookieDictionary() -> [String:String] {
    var dictionary = [String:String]()
    for cookie in self.cookies {
      dictionary[cookie.key] = cookie.value
    }
    return dictionary
  }
  
  //MARK: - Serialization
  
  /**
    This gets a header section for setting all the changes for the cookies in
    this jar.

    It will have one line for each cookie that has been changed, with a newline
    separating the cookies.

    It will also end with a newline.
    */
  public var headerStringForChanges: String {
    get {
      let headers = self.cookies.filter {
        $0.changed
      }.map {
        "Set-Cookie: \($0.headerString)\n"
      }
      return "".join(headers)
    }
  }
}