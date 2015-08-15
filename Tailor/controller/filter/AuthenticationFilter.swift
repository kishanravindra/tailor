/**
  This type provides a filter for authenticating a user before handling a
  request.
  */
public struct AuthenticationFilter: RequestFilterType, Equatable {
  /**
    The URL that we can redirect the user to when they need to sign in.
    */
  public let signInUrl: String
  
  /**
    This initializer creates an authentication filter.

    - parameter signInUrl:  The URL to take the user to when they need to sign
                            in.
    */
  public init(_ signInUrl: String) {
    self.signInUrl = signInUrl
  }
  
  /**
    This method does the preprocessing for the filter.

    This will look for a user using the userId in the request's session. If the
    session has no userId, or it is not a valid user ID, this will redirect to
    the sign-in URL and halt further processing.

    - parameter request:    The request that we are processing.
    - parameter response:   The response so far.
    - parameter callback:   The callback to call with the response.
    */
  public func preProcess(request: Request, var response: Response, callback: (Response, stop: Bool) -> Void) {
    let session = Session(request: request)
    let query = Application.configuration.userType?.query.filter(["id": session["userId"] ?? ""])
    if query?.isEmpty() ?? true {
      response.responseCode = .SeeOther
      response.headers["Location"] = signInUrl
      response.appendString("<html><body>You are being <a href=\"\(signInUrl)\">redirected</a>.")
      callback(response, stop: true)
    }
    else {
      callback(response, stop: false)
    }
  }
  
  /**
    This method does the postprocessing for the filter.

    This will do nothing, and will immediately call the callback with the
    response.

    - parameter request:    The request we are processing.
    - parameter response:   The response so far.
    - parameter callback:   The callback to call with the response.
    */
  public func postProcess(request: Request, response: Response, callback: (Response) -> Void) {
    callback(response)
  }
}

/**
  This method determines if two authentication filters are equal.

  They are equal if they have the same sign-in URL.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two filters are equal.
  */
public func ==(lhs: AuthenticationFilter, rhs: AuthenticationFilter) -> Bool {
  return lhs.signInUrl == rhs.signInUrl
}