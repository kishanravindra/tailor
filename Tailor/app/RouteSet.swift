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
  class Route {
    /** The pattern for the path. */
    let pathPattern: String
    
    /** The method for the HTTP request. */
    let method: String
    
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
    
    /** The controller that will handle the request. */
    var controller: Controller.Type?
    
    /** The name of the action in the controller. */
    var action: String?
    
    /**
      This method initializes a route.

      :param: pathPattern   The pattern for the path.
      :param: handler       The response handler.
      :param: description   The description for the route.
      */
    init(pathPattern: String, method: String, handler: Server.RequestHandler, description: String) {
      self.pathPattern = pathPattern
      self.handler = handler
      self.description = description
      self.method = method
      
      let parameterPattern = NSRegularExpression(pattern: ":[\\w]+", options: nil, error: nil)
      
      var parameterNames : [String] = []
      
      parameterPattern.enumerateMatchesInString(pathPattern, options: nil, range: NSMakeRange(0, countElements(pathPattern)), usingBlock: {
        (match, _, _) in
        let range = Range<String.Index>(start: advance(pathPattern.startIndex, match.range.location + 1), end: advance(pathPattern.startIndex, match.range.location + match.range.length))
        parameterNames.append(pathPattern.substringWithRange(range))
      })
      
      self.pathParameters = parameterNames
      
      var filteredPathPattern = NSMutableString(string: pathPattern)
      
      parameterPattern.replaceMatchesInString(filteredPathPattern, options: nil, range: NSMakeRange(0, countElements(pathPattern)), withTemplate: "([^/]*)")
      self.regex = NSRegularExpression(pattern: "^" + filteredPathPattern + "/?$", options: nil, error: nil)
    }
    
    //MARK: - Description
    
    /**
      This method gets a full description of the route for debugging.
      :returns: The description
      */
    func fullDescription() -> String {
      return NSString(format: "%@ %@", self.pathPattern, self.description)
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
      return match != nil && request.method == self.method
    }
    
    /**
      This method handles a request using the rules in this route.
      
      :param: request   The request to handle.
      :param: callback  The callback that the route should give the response to.
      */
    func handleRequest(request: Request, callback: Server.ResponseCallback) {
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

  /** The prefix for the path that we are adding. */
  private var currentPathPrefix = ""
  
  /** The controller that will be handling requests in a block. */
  private var currentController = Controller.self
  
  //MARK: - Managing Routes

  /**
    This method wraps a block for generating routes.
  
    :param: pathPrefix    The prefix for the paths of the routes.
    :param: block         The block that will provide the routes.
    */
  func withPrefix(pathPrefix: String, block: ()->()) {
    let oldPrefix = self.currentPathPrefix
    self.currentPathPrefix += "/" + pathPrefix
    block()
    self.currentPathPrefix = oldPrefix
  }
  
  /**
    This method establishes a block for generating routes.

    :param: pathPrefix    The prefix for the paths of the routes.
    :param: controller    The controller that will handle the routes.
    :param: block         The block that will provide the routes.
    */
  func withPrefix(pathPrefix: String, controller: Controller.Type, block: ()->()) {
    let oldPrefix = self.currentPathPrefix
    let oldController = self.currentController
    self.currentPathPrefix += "/" + pathPrefix
    self.currentController = controller
    block()
    self.currentController = oldController
    self.currentPathPrefix = oldPrefix
  }
  
  /**
    This method adds a route with a block.

    :param: pathPattern   The pattern for the route.
    :param: handler       The block that will handle the request.
    :param: description   The description of the route implementation.
    */
  func addRoute(pathPattern: String, method: String, handler: Server.RequestHandler, description: String) -> Route {
    var fullPattern = self.currentPathPrefix
    if !pathPattern.isEmpty {
      fullPattern += "/" + pathPattern
    }
    let route = Route(pathPattern: fullPattern, method: method, handler: handler, description: description)
    self.routes.append(route)
    return route
  }
  
  /**
    This method adds a route with a block.

    :param: pathPattern   The pattern for the route.
    :param: method        The HTTP method for the route.
    :param: handler       The block that will handle the request.
  */
  func addRoute(pathPattern: String, method: String, handler: Server.RequestHandler) {
    self.addRoute(pathPattern, method: method, handler: handler, description: "custom block")
  }
  
  /**
    This method adds a route that will be handled by a controller.

    :param: pathPattern   The pattern for the route.
    :param: method        The HTTP method for the route.
    :param: controller    The controller that will handle the requests.
    :param: action        The name of the action in the controller.
    */
  func addRoute(pathPattern: String, method: String, controller: Controller.Type, action: String) {
    let description = NSString(format: "%@#%@", NSStringFromClass(controller), action)
    let handler = {
      (request: Request, callback: Server.ResponseCallback) -> () in
      controller(request: request, action: action, callback: callback).respond()
    }
    let route = self.addRoute(pathPattern, method: method, handler: handler, description: description)
    route.controller = controller
    route.action = action
  }
  
  /**
    This method adds a route that will be handled by the current controller.
    
    :param: pathPattern   The pattern for the route.
    :param: method        The HTTP method for the route.
    :param: action        The name of the action in the controller.
    */
  func addRoute(pathPattern: String, method: String, action: String) {
    self.addRoute(pathPattern, method: method, controller: self.currentController, action: action)
  }
  
  /**
    This method prints information about all of the routes.
    */
  func printRoutes() {
    for route in self.routes {
      NSLog("%@", route.fullDescription())
    }
  }
  
  //MARK: - Handling Requests
  
  /**
    This method handles a request using the first matching route in the route
    set.

    If there is no matching route, it will give a 404 response.

    :param: request   The request that we should handle.
    :param: callback  The callback that we should give the response to.
    */
  func handleRequest(request: Request, callback: Server.ResponseCallback) {
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
  
  //MARK: - Generating URLs
  
  /**
    This method generates a URL using our route set.

    :param: controller    The name of the controller that the link is to.
    :param: action        The name of the action.
    :param: parameters    The parameters to interpolate into the route.
    :returns:             The path, if we could match it up.
    */
  func urlFor(controllerName: String, action: String, parameters: [String:String] = [:]) -> String? {
    for route in self.routes {
      if route.controller != nil && NSStringFromClass(route.controller!) == controllerName &&
      route.action != nil && route.action! == action {
        var path = route.pathPattern
        var hasQuery = false
        for (key, value) in parameters {
          if let range = path.rangeOfString(":" + key, options: nil, range: nil, locale: nil) {
            path = path.stringByReplacingCharactersInRange(range, withString: value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) ?? "")
          }
          else {
            if hasQuery {
              path += "&"
            }
            else {
              path += "?"
              hasQuery = true
            }
            path += key.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) ?? ""
            path += "="
            path += value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) ?? ""
          }
        }
        return path
      }
    }
    return nil
  }
  
  /**
    This method generates a set of routes for static assets.

    The handlers for this will read the file contents for each file from the
    disk and serve it out as the response. The local paths for the assets will
    be relative to the application's root path, which defaults to the directory
    containing the executable.

    :param: prefix        The prefix that we append to all the static asset URLs.
    :param: localPrefix   The prefix that we append to all of the paths for the
                          assets on disk.
    :param: assets        The names of the asset files.
    */
  func staticAssets(#prefix: String, localPrefix: String, assets: [String]) {
    for assetName in assets {
      let path = "\(prefix)/\(assetName)"
      let localPath = "\(localPrefix)/\(assetName)"
      self.addRoute(path, method: "GET") {
        (request, callback) -> () in
        
        let fullPath = Application.sharedApplication().rootPath + "/\(localPath)"

        if let contents = NSFileManager.defaultManager().contentsAtPath(fullPath) {
          var response = Response()
          response.code = 200
          response.bodyData.appendData(contents)
          callback(response)
        }
        else {
          var response = Response()
          response.code = 404
          callback(response)
        }
      }
    }
  }
}