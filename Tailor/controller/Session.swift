import Foundation

/**
  This class provides a session store.

  This will allow storing arbitrary data on the client, persisted between
  requests, without the client being able to read it.
  */
class Session {
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
  init(request: Request) {
    let cookies = request.cookies
    self.clientAddress = request.clientAddress
    self.expirationDate = NSDate(timeIntervalSinceNow: 3600)
    let key = Application.sharedApplication().configFromFile("sessions")["encryptionKey"] as? String
    encryptor = AesEncryptor(key: key ?? "")
    if let encryptedDataString = cookies["_session"] {
      let encryptedData = NSData(base64EncodedString: encryptedDataString, options: nil)
      let decryptedData = encryptor.decrypt(encryptedData)
      
      var cookieData = (NSJSONSerialization.JSONObjectWithData(decryptedData, options: nil, error: nil) as? [String:String]) ?? [:]
      
      if cookieData["clientAddress"] == nil {
        return
      }
      if cookieData["clientAddress"]! != clientAddress {
        return
      }
      if cookieData["expirationDate"] == nil {
        return
      }
      let date : NSDate! = COOKIE_DATE_FORMATTER.dateFromString(cookieData["expirationDate"]!)
      if date == nil {
        return
      }
      if date.compare(NSDate()) == NSComparisonResult.OrderedAscending {
        return
      }
      self.expirationDate = date
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
  }
  
  /**
    This subscript accesses the session data.

    :param: key   The key to access.
    */
  subscript(key: String) -> String? {
    get {
      return self.data[key]
    }
    set {
      self.data[key] = newValue
    }
  }
  
  /**
    This method stores the information for this session in a cookie jar.

    :param: cookies   The cookie jar to put the session info in.
    */
  func storeInCookies(cookies: CookieJar) {
    var mergedData = self.data
    mergedData["clientAddress"] = clientAddress
    mergedData["expirationDate"] = COOKIE_DATE_FORMATTER.stringFromDate(self.expirationDate)
    
    for (key, value) in self.nextFlash {
      mergedData["_flash_\(key)"] = value
    }
    
    let jsonData = NSJSONSerialization.dataWithJSONObject(mergedData, options: nil, error: nil) ?? NSData()
    let encryptedData = encryptor.encrypt(jsonData)
    let encryptedDataString = encryptedData.base64EncodedStringWithOptions(nil)
    cookies["_session"] = encryptedDataString
  }
  
  //MARK: - Flash
  
  /**
    This method gets a value from the flash messages for the current page.

    :param: key     The key for the message.
    :returns:       The message
    */
  func flash(key: String) -> String? {
    return self.currentFlash[key]
  }
  
  /**
    This method sets a value in the flash messages.

    :param: key             The key for the message.
    :param: value           The message
    :param: currentPage     Whether we should set the message for the current
                            page or the next page.
    */
  func setFlash(key: String, _ value: String?, currentPage: Bool = false) {
    if currentPage {
      self.currentFlash[key] = value
    }
    else {
      self.nextFlash[key] = value
    }
  }
}