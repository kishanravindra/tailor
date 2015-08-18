import Foundation

/**
  This class provides a session store.

  This will allow storing arbitrary data on the client, persisted between
  requests, without the client being able to read it.

  To prevent session replay attacks, the session data includes the IP address
  of the request and an expiration date. If the IP address in the session does
  not match the request it's for, this will create a new empty session. If the
  expiration date is in the past, this will create a new empty session. Even if
  the expiration date is in the future, every request will update the session's
  expiration date. The `sessionLifetime` configuration setting specifies how
  far in the future the session should expire.
  */
public struct Session {
  /** The data in the sessions. */
  private var data: [String:String] = [:]
  
  /** The internal encryption object. */
  private let encryptor : AesEncryptor?
  
  /** The IP Address that can use this session. */
  private let clientAddress: String
  
  /** The date when the session will expire. */
  private let expirationDate: Timestamp
  
  /** The flash data for the current page. */
  private var currentFlash: [String:String] = [:]
  
  /** The flash data for the next page. */
  private var nextFlash: [String:String] = [:]
  
  /**
    This method creates a session from request data.
  
    **NOTE**: This has been deprecated in favor of either using the session
    field on the request, or the new initializer that takes the cookie string
    and client address.
  
    - parameter request:   The request.
    */
  @available(*, deprecated, message="You should get the session from the request instead") public init(request: Request) {
    let cookies = request.cookies
    let cookie = cookies["_session"] ?? ""
    self.init(cookieString: cookie, clientAddress: request.clientAddress)
  }
  
  /**
    This initializer creates a session.

    - parameter cookieString:   The cookie string with the encrypted session
                                data.
    - parameter clientAddress:  The address of the client whose session this is.
    */
  public init(cookieString: String, clientAddress: String) {
    encryptor = AesEncryptor(key: Application.configuration.sessionEncryptionKey)
    self.clientAddress = clientAddress
    self.expirationDate = Application.configuration.sessionLifetime.fromNow
    let encryptedData = NSData(base64EncodedString: cookieString, options: []) ?? NSData()
    let decryptedData = encryptor?.decrypt(encryptedData) ?? NSData()
    
    var cookieData: [String:String]
    do {
      cookieData = try NSJSONSerialization.JSONObjectWithData(decryptedData, options: []) as? [String:String] ?? [:]
    }
    catch {
      cookieData = [:]
    }
    let dateString = cookieData["expirationDate"] ?? ""
    
    guard let expirationDate = TimeFormat.Cookie.parseTime(dateString) else { return }
    guard let address = cookieData["clientAddress"] else { return }
    guard address == clientAddress else { return }
    guard expirationDate >= Timestamp.now() else { return }
    
    self.data = cookieData
    
    self.data["clientAddress"] = nil
    self.data["expirationDate"] = nil
    
    for (key, value) in self.data {
      if key.hasPrefix("_flash_") {
        let flashKey = key.substringFromIndex(advance(key.startIndex, 7))
        self.currentFlash[flashKey] = value
        self.data[key] = nil
      }
    }
  }
  
  /**
    This subscript accesses the session data.

    - parameter key:   The key to access.
    */
  public subscript(key: String) -> String? {
    get {
      return self.data[key]
    }
    set {
      self.data[key] = newValue
    }
  }
  
  /**
    - returns:   Whether the session has any data in it.
    */
  public func isEmpty() -> Bool {
    return self.data.isEmpty
  }
  
  //MARK: - Serialization
  
  /**
    This method gets the string for encoding this session in a cookie.
    - returns:   The encoded string.
    */
  public func cookieString() -> String {
    var mergedData = self.data
    mergedData["clientAddress"] = clientAddress
    mergedData["expirationDate"] = self.expirationDate.inTimeZone(TimeZone(name: "GMT")).format(TimeFormat.Cookie)
    
    for (key, value) in self.nextFlash {
      mergedData["_flash_\(key)"] = value
    }
    
    let jsonData = mergedData.toJsonData()
    let encryptedData = encryptor?.encrypt(jsonData) ?? NSData()
    let encryptedDataString = encryptedData.base64EncodedStringWithOptions([])
    return encryptedDataString
  }
  /**
    This method stores the information for this session in a cookie jar.

    - parameter cookies:   The cookie jar to put the session info in.
    */
  public func storeInCookies(inout cookies: CookieJar) {
    cookies["_session"] = self.cookieString()
  }
  
  //MARK: - Flash
  
  /**
    This method gets a value from the flash messages for the current page.

    - parameter key:      The key for the message.
    - returns:            The message
    */
  public func flash(key: String) -> String? {
    return self.currentFlash[key]
  }
  
  /**
    This method sets a value in the flash messages.

    - parameter key:              The key for the message.
    - parameter value:            The message
    - parameter currentPage:      Whether we should set the message for the
                                  current page or the next page.
    */
  public mutating func setFlash(key: String, _ value: String?, currentPage: Bool = false) {
    if currentPage {
      self.currentFlash[key] = value
    }
    else {
      self.nextFlash[key] = value
    }
  }
}