import Foundation

/**
  This struct represents a cookie that is stored in and retrieved from the
  client.
  */
public struct Cookie: Equatable {
  //MARK: - Reading Cookies
  
  /** The identifier for the cookie. */
  public let key: String
  
  /** The value stored in the cookie. */
  public var value: String
  
  /**
  This method initializes a cookie.
  
  - parameter key:     The identifier for the cookie.
  - parameter value:   The value for the cookie.
  */
  public init(key: String, value: String) {
    self.key = key
    self.value = value
  }
  
  //MARK: - Updating Cookies
  
  /**
    Whether the cookie has been changed from the current value on the client.
    */
  public var changed: Bool = false
  
  /**
    The subpath on the site that the cookie is set to.
  
    The cookie will be sent for requests to this path and its subpaths, and not
    sent for any other requests.
    */
  public var path: String = "/"
  
  /**
    The domain for the cookie.

    If your site is running on a sudomain, you can set this to the parent domain
    to make the cookie available to all subdomains.
    */
  public var domain: String? = nil
  
  /**
    The time when the cookie will expire.
    */
  public var expiresAt: Timestamp? = nil
  
  /**
    The number of seconds from now when the cookie will expire.
    */
  public var maxAge: Int? = nil
  
  /**
    Whether the cookie should only be sent over connections secured with SSL.
    */
  public var secureOnly: Bool = false
  
  /**
    Whether the cookie should only be set over HTTP/HTTPS.
    */
  public var httpOnly: Bool = false
  
  //MARK: - Serialization
  
  /**
    This method gets a string than can be put in a Set-Cookie header to update
    the value for this cookie.
    */
  public var headerString : String {
    get {
      var string = "\(self.key)=\(self.value)"
      
      let expirationString : String? = expiresAt?.inTimeZone(TimeZone(name: "GMT")).format(TimeFormat.Cookie)
      
      let ageString: String?
      if let age = maxAge { ageString = String(age) } else { ageString = nil }
      
      let pairs : [(String,String?)] = [
        ("Path", self.path),
        ("Expires", expirationString),
        ("Domain", self.domain),
        ("Max-Age", ageString)
      ]
      for (name, value) in pairs {
        if let value = value {
          string += "; \(name)=\(value)"
        }
      }
      if self.secureOnly {
        string += "; Secure"
      }
      
      if self.httpOnly {
        string += "; HttpOnly"
      }
      
      return string
    }
  }
}

/**
  This method determines if two cookies are equal.

  Cookies are equal when all of their fields are equal.

  - parameter lhs:    The left-hand side of the operator
  - parameter rhs:    The right-hand side of the operator
  - returns:          Whether the two cookies are equal.
  */
public func ==(lhs: Cookie, rhs: Cookie) -> Bool {
  return lhs.key == rhs.key &&
    lhs.value == rhs.value &&
    lhs.changed == rhs.changed &&
    lhs.domain == rhs.domain &&
    lhs.expiresAt == rhs.expiresAt &&
    lhs.httpOnly == rhs.httpOnly &&
    lhs.maxAge == rhs.maxAge &&
    lhs.path == rhs.path &&
    lhs.secureOnly == rhs.secureOnly
}
