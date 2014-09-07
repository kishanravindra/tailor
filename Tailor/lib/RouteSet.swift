import Foundation

/**
  This class manages a set of routes that map from request paths to
  response handlers.
  */
class RouteSet {
  /**
    This class models a single route.

    A route maps a pattern for a request path to the implementation of the
    response.
  
    The path pattern is a regex that the route will apply to the path to see if
    the route can accept the request. It can also contain segments with the
    format `:parameter_name`, which will capture a variable portion of the route
    in a request parameter called `parameter_name`.
    */
  struct Route {
    /** The pattern for the path. */
    let pathPattern: String
    
    /** The implementation of the response handler. */
    let handler: Server.RequestHandler
    
    /** A description of the route for logging purposes. */
    let description: String
    
    /**
      The regex that we apply to determine if the route can handle the path.
      */
    let regex: NSRegularExpression
    
    /**
      The names of the request parameters that this route extracts from the
      path.
      */
    let pathParameters: [String]
    
    /**
      This method initializes a route.

      :param: pathPattern   The pattern for the path.
      :param: handler       The response handler.
      :param: description   The description for the route.
      */
    init(pathPattern: String, handler: Server.RequestHandler, description: String) {
      self.pathPattern = pathPattern
      self.handler = handler
      self.description = description
      
      let parameterPattern = NSRegularExpression(pattern: ":[\\w]+", options: nil, error: nil)
      
      var parameterNames : [String] = []
      
      parameterPattern.enumerateMatchesInString(pathPattern, options: nil, range: NSMakeRange(0, countElements(pathPattern)), usingBlock: {
        (match, _, _) in
        let range = Range<String.Index>(start: advance(pathPattern.startIndex, match.range.location + 1), end: advance(pathPattern.startIndex, match.range.location + match.range.length))
        parameterNames.append(pathPattern.substringWithRange(range))
      })
      
      self.pathParameters = parameterNames
      
      var filteredPathPattern = NSMutableString(string: pathPattern)
      
      parameterPattern.replaceMatchesInString(filteredPathPattern, options: nil, range: NSMakeRange(0, countElements(pathPattern)), withTemplate: "(.*)")
      self.regex = NSRegularExpression(pattern: filteredPathPattern, options: nil, error: nil)
    }
    
    //MARK: - Request Handling
    
    /**
      This method determines if this route can handle a request.

      :param: request   The request to check.
      :returns:         Whether the route can handle the request.
      */
    func canHandleRequest(request: Request) -> Bool {
      let path = request.path
      let range = NSRange(location: 0, length: countElements(path))
      let match = self.regex.firstMatchInString(path, options: nil, range: range)
      return match != nil
    }
    
    /**
      This method handles a request using the rules in this route.
      
      :param: request   The request to handle.
      :param: callback  The callback that the route should give the response to.
      */
    func handleRequest(request: Request, callback: (Response)->()) {
      NSLog("Processing with %@", self.description)
      var requestCopy = request
      let path = request.path
      let range = NSRange(location: 0, length: countElements(path))
      
      let parameterValues = Request.extractWithPattern(path, pattern: self.regex.pattern)
      for (index, key) in enumerate(self.pathParameters) {
        requestCopy.requestParameters[key] = parameterValues[index]
      }
      
      NSLog("Parameters: %@", requestCopy.requestParameters)
      self.handler(requestCopy, callback)
    }
  }
  
  //MARK: -
  
  /** The routes in the set. */
  private(set) var routes : [Route] = []
  
  //MARK: - Adding Routes
  
  /**
    This method adds a route with a block.

    :param: pathPattern   The pattern for the route.
    :param: handler       The block that will handle the request.
    */
  func addRoute(pathPattern: String, handler: Server.RequestHandler) {
    self.routes.append(Route(pathPattern: pathPattern, handler: handler, description: "custom block"))
  }
  
  //MARK: - Handling Requests
  
  /**
    This method handles a request using the first matching route in the route
    set.

    If there is no matching route, it will give a 404 response.

    :param: request   The request that we should handle.
    :param: callback  The callback that we should give the response to.
    */
  func handleRequest(request: Request, callback: (Response)->()) {
    NSLog("Processing %@ %@", request.method, request.path)
    for route in self.routes {
      if route.canHandleRequest(request) {
        route.handleRequest(request, callback: callback)
        return
      }
    }
    NSLog("Unable to handle request")
    var response = Response()
    response.code = 404
    response.appendString("File Not Found")
    callback(response)
  }
}