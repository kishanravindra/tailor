/**
  This type provides a filter for checking that a non-idempotent request has a
  CSRF token in its request parameters matching the one in the session.

  If the tokens don't match, this will render a 403 Unauthorized response. If
  there is no CSRF token in the session, this will generate one prior to doing
  the comparison.

  The tokens are stored in the key "csrfKey" in the session, and "_csrfKey" in
  the request parameters. The Tailor form builders add the key to the request
  parameters automatically, but if you are not using those form builders you
  will have to add it yourself.

  This filter is applied by default to all requests.
  */
public struct CsrfFilter: RequestFilterType, Equatable {
  /**
    This initializer creates a CSRF token filter.
    */
  public init() {
    
  }
  
  /**
    This method performs the check for the matching CSRF tokens in the request
    parameters and the session.

    - parameter request:    The request we are checking.
    - parameter response:   The response so far.
    - parameter callback:   A callback to call with our response.
    */
  public func preProcess(request: Request, response: Response, callback: (Request, Response, stop: Bool) -> Void) {
    var request = request
    var response = response
    let key: String
    if let sessionKey = request.session["csrfKey"] {
      key = sessionKey
    }
    else {
      key = AesEncryptor.generateKey()
      request.session["csrfKey"] = key
    }
    let parameterKey = request.params["_csrfKey"] as String
    if parameterKey != key && request.method != "GET" {
      NSLog("Request cannot continue because it lacks a valid CSRF token. See documentation for CsrfFilter for more information.")
      response.responseCode = .Forbidden
      response.appendString("That action cannot be completed because of a security restriction.")
      callback(request, response, stop: true)
      return
    }
    
    callback(request, response, stop: false)
  }
  
  /**
    This method performs post processing for the filters.

    This does nothing, and will call the callback immediately.

    - parameter request:    The request we are processing.
    - parameter response:   The response so far.
    - parameter callback:   The callback to call with the response.
    */
  public func postProcess(request: Request, response: Response, callback: Connection.ResponseCallback) {
    callback(response)
  }
}

/**
  This method determines if two CSRF filters are equal.

  This always returns true.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two filters are equal.
  */
public func ==(lhs: CsrfFilter, rhs: CsrfFilter) -> Bool {
  return true
}