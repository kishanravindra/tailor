import Foundation

/**
  This type represents a response to a request.
  */
public struct Response: HttpMessageType, Equatable {
  /**
    This type represents a response code in a response.
    
    This type provides several constants for the response codes defined in
    RFC 2068, but you can also use custom response codes by using the
    initializer.
    */
  public struct Code: Equatable {
    /** The numeric code, e.g. 200 */
    public let code: Int
    
    /** The human-readable description, e.g. OK */
    public let description: String
    
    /**
      This initializer creates a custom response code.

      - parameter code:           The numeric code
      - parameter description:    The human-readable description.
      */
    public init(_ code: Int, _ description: String) {
      self.code = code
      self.description = description
    }
    
    /**
      This response indicates that the headers are acceptable and that the
      client should send the remainder of the request.
      */
    public static let Continue = Code(100, "Continue")
    
    /**
      This response indicates that the server is willing to switch protocols to
      match the upgrade options that the client has presented.
      */
    public static let SwitchingProtocols = Code(101, "Switching Protocols")
    
    /**
      This response indicates that the request has succeeded and is returning
      the entity that the client has requested.
      */
    public static let Ok = Code(200, "OK")
    
    /**
      This response indicates that the request has succeeded and is returning
      the entity that was created in response to the request.
      */
    public static let Created = Code(201, "Created")
    
    /**
      This response indicates that the request to create a new entity has been
      accepted for later processing, but has not been fully completed.
      */
    public static let Accepted = Code(202, "Accepted")
    
    /**
      This response indicates that the response contains the information that
      has been requested, but that it may not be the most correct version of
      that information.
      */
    public static let NonAuthoritativeInformation = Code(203, "Non-Authoritative Information")
    
    /**
      This response indicates that the request has been fulfilled but that there
      is no information to send back.
      */
    public static let NoContent = Code(204, "No Content")
    
    /**
      This response indicates that the request has been fulfilled and that the
      client should reset the form on its end.
      */
    public static let ResetContent = Code(205, "Reset Content")
    
    /**
      This response indicates that the response contains a partial version of
      the requested entity, as specified by the Range header in the request and
      the Content-Range header in the response.
      */
    public static let PartialContent = Code(206, "Partial Content")
    
    /**
      This response indicates that the requested entity can be found at multiple
      different locations.
      */
    public static let MultipleChoices = Code(300, "Multiple Choices")
    
    /**
      This response indicates that the requested entity has been permanently
      moved to a different location.
      */
    public static let MovedPermanently = Code(301, "Moved Permanently")
    
    /**
      This response indicates that the requested entity has been temporarily
      moved to a different location.
      */
    public static let Found = Code(302, "Found")
    
    /**
      This response indicates that the real response can be found at a different
      URI.

      This is the best response code to use when redirecting from a POST request
      to another page showing the result of that request.
      */
    public static let SeeOther = Code(303, "See Other")
    
    /**
      This response is used when the request contains cache-related information,
      and the result will match the value that the client has cached.
      */
    public static let NotModified = Code(304, "Not Modified")
    
    /**
      This response indicates that the request can only be fulfilled by going
      through a proxy specified in the Location header field.
      */
    public static let UseProxy = Code(305, "Use Proxy")
    
    /**
      This response indicates that the requested entity is temporarily
      available under a different URI.
    */
    public static let TemporaryRedirect = Code(307, "Temporary Redirect")
    
    /**
      This response indicates that the syntax of the request is bad.
      */
    public static let BadRequest = Code(400, "Bad Request")
    
    /**
      This response indicates that the client must provide additional
      authentication information before they can access the entity.
      */
    public static let Unauthorized = Code(401, "Unauthorized")
    
    /**
      This response indicates that the server will not fulfill the request, and
      that the client should not attempt to re-authenticate.
      */
    public static let Forbidden = Code(403, "Forbidden")
    
    /**
      This response indicates that there is no entity at the requested URI.
      */
    public static let NotFound = Code(404, "Not Found")
    
    /**
      This response indicates that the entity at the requested URI cannot be
      accessed by the HTTP method that the client is attempting to use.
      */
    public static let MethodNotAllowed = Code(405, "Method Not Allowed")
    
    /**
      This response indicates that the Accept- headers in the request are
      incompatible with the types of responses that the server can generated.
      */
    public static let NotAcceptable = Code(406, "Not Acceptable")
    
    /**
      This response indicates that the client must authenticate itself with a
      proxy before making requests to this server.
      */
    public static let ProxyAuthenticationRequired = Code(407, "Proxy Authentication Required")

    /**
      This response indicates that the server was waiting for the client to
      continue sending the request, but that the client took too long.
      */
    public static let RequestTimeout = Code(408, "Request Timeout")
    
    /**
      This response indicates that the version of the entity that the client
      supplied conflicted with the version on the server.
      */
    public static let Conflict = Code(409, "Conflict")
    
    /**
      This response that the requested entitity has been removed permanently.
      */
    public static let Gone = Code(410, "Gone")
    
    /**
      This response indicates that the client has attempted to send a request
      without a content length, but that the server requires it.
      */
    public static let LengthRequired = Code(411, "Length Required")
    
    /**
      This response indicates that the request headers specified preconditions
      about the requested entity that are not met on the server.
      */
    public static let PreconditionFailed = Code(412, "Precondition Failed")
    
    /**
      This response indicates that the entity being supplied by the request is
      lager than the server can handle.
      */
    public static let RequestEntityTooLarge = Code(413, "Request Entity Too Large")
    
    /**
      This response indicates that the URI in the reqeust is larger than the
      server can interpret.
      */
    public static let RequestUriTooLong = Code(414, "Request-URI Too Long")
    
    /**
      This response indicates that the content-type of the entity in the request
      cannot be interpreted by the server.
      */
    public static let UnsupportedMediaType = Code(415, "Unsupported Media Type")
    
    /**
      This response indicates that the range of content that the client has
      requested cannot be provided by the server.
      */
    public static let RequestedRangeNotSatisfiable = Code(416, "Requested Range Not Satisfiable")
    
    /**
      This response indicates that the client provided an expectation in the
      Expect header that the server cannot meet.
      */
    public static let ExpectationFailed = Code(417, "Expectation Failed")
    
    /**
      This response indicates that the server has encountered a general
      problem handling the request.
      */
    public static let InternalServerError = Code(500, "Internal Server Error")
    
    /**
      This method indicates that the functionality described by the request is
      not provided by the server.
      */
    public static let NotImplemented = Code(501, "Not Implemented")
    
    /**
      This method indicates that the server was acting as a proxy but that the
      upstream server refused the connection.
      */
    public static let BadGateway = Code(502, "Bad Gateway")
    
    /**
      This method indicates that the service being requested is temporarily
      unavailable due to overloading or maintenance.
      */
    public static let ServiceUnavailable = Code(503, "Service Unavailable")
    
    /**
      This method indicates that the server was acting as a proxy but that the
      upstream server did not respond in a timely fashion.
      */
    public static let GatewayTimeout = Code(504, "Gateway Timeout")
    
    /**
      This method indicates that the server cannot support the HTTP version
      specified in the request.
      */
    public static let HttpVersionNotSupported = Code(505, "HTTP Version Not Supported")
  }
  
  /** The HTTP status line. */
  public var statusLine: String {
    return "HTTP/1.1 \(responseCode.code) \(responseCode.description)"
  }

  /**
    The HTTP response code.
    */
  public var responseCode = Code.Ok
  
  /** The response headers. */
  public var headers: [String:String] = [:]
  
  /** The cookies that should be updated with this response. */
  public var cookies = CookieJar()

  /** The data in the body of the message. */
  public var bodyData = NSData()
  
  /** The templates that were rendered to produce this response. */
  public var renderedTemplates: [TemplateType] = []

  /** Whether this message type sets cookies rather than reading them. */
  public let setsCookies = true
  
  /**
    Whether this response has a defined length that will be sent all at once.

    You can set this to false when sending chunked responses, or other responses
    that can be streamed out in pieces.

    When this is false, the response will not set an automatic content-length
    header. It will also prevent the connection from being automatically closed
    or prompted for input until we have sent a response with an empty body.
    */
  public var hasDefinedLength = true
  
  /**
    This method specifies that this response should only contain a body, not any
    headers.
  
    This can be used when sending out the body of a chunked response or any
    other kind of streamed response.
    */
  public var bodyOnly = false
  
  /**
    This method provides a callback that should be invoked once the response is
    sent.

    The callback will receive a flag indicating whether it should continue
    producing more parts of the response. This will be false when the connection
    has been closed on the other end, so you can use this to detect whether you
    should stop producing a streamed response.
    */
  public var continuationCallback: ((Bool)->Void)? = nil
  
  /**
    This flag determines whether a response is chunked.

    This determines it based on the Transfer-Encoding header.
  
    The first part of a chunked response should contain only the headers.
    After that, you should call the response callback again with each part of
    the body. The sections containing the body should have the `bodyOnly` flag
    set to true, and the `hasDefinedLength` flag set to true.
  
    The system will automatically add a prefix to the body chunks with the
    length of the chunk.
    */
  public var chunked: Bool {
    return self.headers["Transfer-Encoding"]?.hasPrefix("chunked") ?? false
  }
  
  /**
    This method initializes an empty response.
    */
  public init() {
    
  }

  /**
    This initializer creates a response from the HTTP message components.
    */
  public init(statusLine: String, headers: [String:String], cookies: CookieJar, bodyData: NSData) {
    let statusComponents = statusLine.componentsSeparatedByString(" ")
    if statusComponents.count > 2 {
      if let code = Int(statusComponents[1]) {
        self.responseCode = Code(code, statusComponents[2])
      }
      else {
        self.responseCode = Code(500, "Invalid response format")
      }
    }
    else {
      self.responseCode = Code(500, "Invalid response format")
    }
    self.headers = headers
    self.cookies = cookies
    self.bodyData = bodyData
  }
  
  //MARK: - Response Data

  /**
    A copy of the body data.

    This has been deprecated in favor of bodyData.
    */
  @available(*, deprecated, message="Use bodyData instead")
  public var body: NSData { return self.bodyData }
  
  /**
    The string version of the response body.

    This has been deprecated in favor of bodyText.
    */
  @available(*, deprecated, message="Use bodyText instead")
  public var bodyString: String { get {
    return self.bodyText
  } }
}


/**
  This method determines if two responses are equal.

  Responses are equal if they have the same code, headers, body data, and
  cookies.

  - parameter lhs:    The left-hand side of the operator
  - parameter rhs:    The right-hand side of the operator
  - returns:          Whether the two responses are equal.
  */
public func ==(lhs: Response, rhs: Response) -> Bool {
  return lhs.responseCode == rhs.responseCode &&
    lhs.headers == rhs.headers &&
    lhs.bodyData == rhs.bodyData &&
    lhs.cookies == rhs.cookies
}

/**
  This method determines if two response codes are equal.

  The codes are equal if they have the same code and description.

  - parameter lhs:    The left-hand side of the comparison.
  - parameter rhs:    The right-hand side of the comparison.
  - returns:          Whether the two codes are equal.
  */
public func ==(lhs: Response.Code, rhs: Response.Code) -> Bool {
  return lhs.code == rhs.code && lhs.description == rhs.description
}