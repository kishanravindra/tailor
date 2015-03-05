import Foundation

/**
  This class provides a session store.

  This will allow storing arbitrary data on the client, persisted between
  requests, without the client being able to read it.
  */
public class Session {
  /** The data in the sessions. */
  private var data: [String:String] = [:]
  
  /** The internal encryption object. */
  private let encryptor : AesEncryptor
  
  /** The IP Address that can use this session. */
  private let clientAddress: String
  
  /** The date when the session will expire. */
  private let expirationDate: NSDate
  
  /** The flash data for the current page. */
  private var currentFlash: [String:String] = [:]
  
  /** The flash data for the next page. */
  private var nextFlash: [String:String] = [:]
  
  /**
    This method creates a session from request data.
    
    :param: request   The request.
    */
  public init(request: Request) {
    let cookies = request.cookies
    self.clientAddress = request.clientAddress
    self.expirationDate = NSDate(timeIntervalSinceNow: 3600)
    let key = Application.sharedApplication().configuration["sessions.encryptionKey"]
    encryptor = AesEncryptor(key: key ?? "")
    if let encryptedDataString = cookies["_session"] {
      let encryptedData = NSData(base64EncodedString: encryptedDataString, options: nil) ?? NSData()
      let decryptedData = encryptor.decrypt(encryptedData)
      
      var cookieData = (NSJSONSerialization.JSONObjectWithData(decryptedData, options: nil, error: nil) as? [String:String]) ?? [:]
      let dateString = cookieData["expirationDate"] ?? ""
      
      self.expirationDate = COOKIE_DATE_FORMATTER.dateFromString(dateString) ?? NSDate(timeIntervalSinceNow: 3600)
      
      if cookieData["clientAddress"] == nil {
        return
      }
      if cookieData["clientAddress"]! != clientAddress {
        return
      }
      if cookieData["expirationDate"] == nil {
        return
      }
      if self.expirationDate.compare(NSDate()) == NSComparisonResult.OrderedAscending {
        return
      }
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
    else {
      self.expirationDate = NSDate(timeIntervalSinceNow: 3600)
    }
  }
  
  /**
    This subscript accesses the session data.

    :param: key   The key to access.
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
    :returns:   Whether the session has any data in it.
    */
  public func isEmpty() -> Bool {
    return self.data.isEmpty
  }
  
  //MARK: - Serialization
  
  /**
    This method gets the string for encoding this session in a cookie.
    :returns:   The encoded string.
    */
  public func cookieString() -> String {
    var mergedData = self.data
    mergedData["clientAddress"] = clientAddress
    mergedData["expirationDate"] = COOKIE_DATE_FORMATTER.stringFromDate(self.expirationDate)
    
    for (key, value) in self.nextFlash {
      mergedData["_flash_\(key)"] = value
    }
    
    let jsonData = NSJSONSerialization.dataWithJSONObject(mergedData, options: nil, error: nil) ?? NSData()
    let encryptedData = encryptor.encrypt(jsonData)
    let encryptedDataString = encryptedData.base64EncodedStringWithOptions(nil)
    return encryptedDataString
  }
  /**
    This method stores the information for this session in a cookie jar.

    :param: cookies   The cookie jar to put the session info in.
    */
  public func storeInCookies(cookies: CookieJar) {
    cookies["_session"] = self.cookieString()
  }
  
  //MARK: - Flash
  
  /**
    This method gets a value from the flash messages for the current page.

    :param: key     The key for the message.
    :returns:       The message
    */
  public func flash(key: String) -> String? {
    return self.currentFlash[key]
  }
  
  /**
    This method sets a value in the flash messages.

    :param: key             The key for the message.
    :param: value           The message
    :param: currentPage     Whether we should set the message for the current
                            page or the next page.
    */
  public func setFlash(key: String, _ value: String?, currentPage: Bool = false) {
    if currentPage {
      self.currentFlash[key] = value
    }
    else {
      self.nextFlash[key] = value
    }
  }
}