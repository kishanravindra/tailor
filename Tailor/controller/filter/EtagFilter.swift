/**
  This type provides a filter for attaching ETag headers, and sending a
  Not-Modified response if the request's ETag matches the body.

  The ETags used by this type are MD5 hashes of the data.
  */
public struct EtagFilter: RequestFilterType, Equatable {
  /**
    This initializer creates an ETag filter.
    */
  public init() {
    
  }
  
  /**
    This method provides preprocessing before a request is handled.

    This does nothing and immediately calls the callback.

    - parameter request:    The request to process
    - parameter response:   The response so far.
    - parameter callback:   A callback to call with the response after the
                            filter runs.
    */
  public func preProcess(request: Request, response: Response, callback: (Request, Response, stop: Bool)->Void) {
    callback(request, response, stop: false)
  }
  
  /**
    This method provides postprocessing after a request is handled.

    This will take an MD5 hash of the response body and use it as an ETag.
    If the request has provided an If-None-Match header matching the ETag,
    this will remove the response body and set a Not-Modified response code.
    
    If the response is not an OK response, this will not set any ETag.

    - parameter request:    The request that we are processing
    - parameter response:   The response so far.
    - parameter callback:   The callback to call with the modified response.
    */
  public func postProcess(request: Request, var response: Response, callback: Connection.ResponseCallback) {
    if response.responseCode == .Ok {
      let tag = response.body.md5Hash
      response.headers["ETag"] = tag
      if request.headers["If-None-Match"] == tag {
        response.responseCode = .NotModified
        response.clearBody()
      }
    }
    callback(response)
  }
}

/**
  This method determines if two ETag filters are equal.

  ETag filters are always equal.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          True. Always true.
  */
public func ==(lhs: EtagFilter, rhs: EtagFilter) -> Bool {
  return true
}