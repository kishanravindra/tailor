/**
  This type provides a filter for authenticating a user before handling a
  request.
   
  This will look for a user using the userId in the request's session. If the
  session has no userId, or it is not a valid user ID, this will redirect to
  the sign-in URL and halt further processing. It will also put the original
  request path in the session under the key `_redirectPath`.
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
    This method generates a redirect response from an authentication failure.

    - parameter response:   The initial response from the other filters.
    - returns:              The redirect response.
    */
  private func redirectResponse(request: Request, var _ response: Response) -> Response {
    var session = request.session
    session["_redirectPath"] = request.path
    session.storeInCookies(&response.cookies)
    response.responseCode = .SeeOther
    response.headers["Location"] = signInUrl
    response.appendString("<html><body>You are being <a href=\"\(signInUrl)\">redirected</a>.")
    return response
  }
  
  /**
    This method gets a user from the request information.
    
    If the user cannot be fetched, this will throw an error giving a redirect
    to the sign-in page.
  
    - parameter request:    The request that we are responding to.
    - parameter response:   The initial response from the other filters.
    - returns:              The fetched user.
    */
  public func fetchUser<T: UserType>(request: Request, response: Response) throws -> T {
    let userId = Int(request.session["userId"] ?? "0") ?? 0
    let query = T.query.filter(["id": userId]).limit(1)
    let record = query.allRecords().first
    guard let user = record as? T else {
      throw ControllerError.UnprocessableRequest(redirectResponse(request, response))
    }
    return user
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
  public func preProcess(request: Request, response: Response, callback: (Request, Response, stop: Bool) -> Void) {
    let session = request.session
    let query = Application.configuration.userType?.query.filter(["id": session["userId"] ?? ""])
    if query?.isEmpty() ?? true {
      callback(request, redirectResponse(request, response), stop: true)
    }
    else {
      callback(request, response, stop: false)
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
  public func postProcess(request: Request, response: Response, callback: Connection.ResponseCallback) {
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