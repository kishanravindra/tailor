import Foundation

/**
  This class manages a set of routes that map from request paths to
  response handlers.
  */
public class RouteSet {
  /**
    This class models a single route.

    A route maps a pattern for a request path to the implementation of the
    response.
  
    The path pattern is a regex that the route will apply to the path to see if
    the route can accept the request. It can also contain segments with the
    format `:parameter_name`, which will capture a variable portion of the route
    in a request parameter called `parameter_name`.
    */
  public struct Route {
    /** The pattern for the path. */
    public let pathPattern: String
    
    /** The method for the HTTP request. */
    public let method: String
    
    /** The implementation of the response handler. */
    public let handler: Connection.RequestHandler
    
    /** A description of the route for logging purposes. */
    public let description: String
    
    /**
      The regex that we apply to determine if the route can handle the path.
    
      This is nil when we try to initialize a route with an ill-formatted expression.
      */
    public let regex: NSRegularExpression?
    
    /**
      The names of the request parameters that this route extracts from the
      path.
      */
    public let pathParameters: [String]
    
    /** The controller that will handle the request. */
    public private(set) var controller: ControllerType.Type?
    
    /** The name of the action in the controller. */
    public private(set) var actionName: String?
    
    /**
      This method initializes a route.

      - parameter pathPattern:   The pattern for the path.
      - parameter handler:       The response handler.
      - parameter description:   The description for the route.
      */
    public init(pathPattern: String, method: String, handler: Connection.RequestHandler, description: String) {
      self.pathPattern = pathPattern
      self.handler = handler
      self.description = description
      self.method = method
      
      let parameterPattern = try! NSRegularExpression(pattern: ":[\\w]+", options: [])
      
      var parameterNames : [String] = []
      
      parameterPattern.enumerateMatchesInString(pathPattern, options: [], range: NSMakeRange(0, pathPattern.characters.count), usingBlock: {
        (match, _, _) in
        guard let match = match else { return }
        let range = Range<String.Index>(start: advance(pathPattern.startIndex, match.range.location + 1), end: advance(pathPattern.startIndex, match.range.location + match.range.length))
        parameterNames.append(pathPattern.substringWithRange(range))
      })
      
      self.pathParameters = parameterNames
      
      let filteredPathPattern = NSMutableString(string: pathPattern)
      
      parameterPattern.replaceMatchesInString(filteredPathPattern, options: [], range: NSMakeRange(0, pathPattern.characters.count), withTemplate: "([^/]*)")
      
      do {
        try self.regex = NSRegularExpression(pattern: "^" + (filteredPathPattern as String) + "/?$", options: [])
      }
      catch {
        self.regex = nil
      }
    }
    
    //MARK: - Description
    
    /**
      This method gets a full description of the route for debugging.
      - returns: The description
      */
    public func fullDescription() -> String {
      return NSString(format: "%@ %@ %@", self.method, self.pathPattern, self.description) as String
    }
    
    //MARK: - Request Handling
    
    /**
      This method determines if this route can handle a request.

      - parameter request:    The request to check.
      - returns:              Whether the route can handle the request.
      */
    public func canHandleRequest(request: Request) -> Bool {
      let path = request.path
      let range = NSRange(location: 0, length: path.characters.count)
      let match = self.regex?.firstMatchInString(path, options: [], range: range)
      return match != nil && request.method == self.method
    }
    
    /**
      This method handles a request using the rules in this route.
      
      - parameter request:   The request to handle.
      - parameter callback:  The callback that the route should give the response to.
      */
    public func handleRequest(request: Request, callback: Connection.ResponseCallback) {
      NSLog("Processing with %@", self.description)
      var requestCopy = request
      let path = request.path
      
      let parameterValues = Request.extractWithPattern(path, pattern: self.regex?.pattern ?? "")
      for (index, key) in self.pathParameters.enumerate() {
        requestCopy.requestParameters[key] = parameterValues[index]
      }
      
      NSLog("Parameters: %@", requestCopy.requestParameters)
      self.handler(requestCopy, callback)
    }
  }
  
  //MARK: -
  
  /** The routes in the set. */
  public private(set) var routes : [Route] = []

  /** The prefix for the path that we are adding. */
  private var currentPathPrefix = ""
  
  /** The controller that will be handling requests in a block. */
  private var currentController: ControllerType.Type?
  
  /** The filters that we will apply to the current request. */
  private var currentFilters: [(ControllerType)->Void->Bool] = []
  
  /**
    This method creates an empty route set.
    */
  public init() {
    
  }
  
  /**
    This method gets the shared route set for the application.
    */
  public class func shared() -> RouteSet {
    return Application.sharedApplication().routeSet
  }
  
  //MARK: - Managing Routes

  /**
    This method wraps a block for generating routes.
  
    This method is deprecated. You should use `withScope` instead.
  
    - parameter pathPrefix:    The prefix for the paths of the routes.
    - parameter block:         The block that will provide the routes.
    */
  @available(*, deprecated, message="Use withScope instead") public func withPrefix(pathPrefix: String, @noescape block: ()->()) {
    let oldPrefix = self.currentPathPrefix
    self.currentPathPrefix += "/" + pathPrefix
    block()
    self.currentPathPrefix = oldPrefix
  }
  
  /**
    This method establishes a block for generating routes.

    - parameter pathPrefix:    The prefix for the paths of the routes.
    - parameter controller:    The controller that will handle the routes.
    - parameter block:         The block that will provide the routes.
    */
  @available(*, deprecated) public func withPrefix(pathPrefix: String, controller: Controller.Type, @noescape block: ()->()) {
    let oldPrefix = self.currentPathPrefix
    let oldController = self.currentController
    self.currentPathPrefix += "/" + pathPrefix
    self.currentController = controller
    block()
    self.currentController = oldController
    self.currentPathPrefix = oldPrefix
  }
  
  /**
    This method creates a scope that will apply to several routes.

    - parameter path:     A segment of a path that will be applied to the
                          beginning of the routes. There will be a slash added
                          to the beginning of this segment.
    - parameter block:    A block that will add the specific routes.
    */
  public func withScope(path path: String? = nil, @noescape block: Void->Void) {
    let oldPrefix = self.currentPathPrefix
    if let path = path {
      self.currentPathPrefix += "/" + path
    }
    block()
    self.currentPathPrefix = oldPrefix
  }
  
  /**
    This method creates a scope that will apply to several routes.
  
    This allows you to add filters that will be run before the controller
    action. The filters take in a controller and return a function that will
    return a boolean. The boolean return value should indicate whether the
    request passed the filter. Filters can check if a request has all the
    necessary parameters, or if the parameters are consistent with other parts
    of the state of the system, or anything else that you want to be a reusable
    check. 
  
    The type signature for filters is designed to work well with Swift's method
    currying. If you have an instance method called `authenticate` on
    `MyController` that returns a boolean, you can use it as a filter by passing
    `MyController.authenticate` in the filter list for this method.

    As soon as one of the filters returns false, we will stop all processing.
    Any filter that returns false must also generate a response.
  
    The filters will only be applied to controller actions.

    - parameter path:       A segment of a path that will be applied to the
                            beginning of the routes. There will be a slash added
                            to the beginning of this segment.
    - parameter filters:    The filters to run.
    - parameter block:      A block that will add the specific routes.
    */
  public func withScope<T: ControllerType>(path path: String? = nil, filters: [(T)->Void->Bool] = [], @noescape block: Void->Void) {
    let oldPrefix = self.currentPathPrefix
    if let path = path {
      self.currentPathPrefix += "/" + path
    }
    let oldFilters = self.currentFilters
    
    let castFilters = filters.map {
      filter in
      return {
        (controller: ControllerType)->Void->Bool in
        return {
          ()->Bool in
          let castController = controller as? T
          if castController != nil {
            return filter(castController!)()
          }
          else {
            controller.render404()
            return false
          }
        }
      }
    }
    let newFilters = currentFilters + castFilters
    self.currentFilters = newFilters
    block()
    self.currentFilters = oldFilters
    self.currentPathPrefix = oldPrefix
  }
  
  
  /**
    This method creates a scope that will apply to several routes.
  
    - parameter path:     A segment of a path that will be applied to the
                          beginning of the routes. There will be a slash added
                          to the beginning of this segment.
    - parameter filter:   The filter to run. For more details on how filters
                          work, see the documentation for the `withScope` method
                          that accepts multiple filters.
    - parameter block:    A block that will add the specific routes.
    */
  public func withScope<T: ControllerType>(path path: String? = nil, filter: (T)->Void->Bool, @noescape block: Void->Void) {
    self.withScope(path: path, filters: [filter], block: block)
  }
  
  /**
    This method sets up a redirect from one path to the other.

    - parameter pathPattern:   The regular expression for the incoming path.
    - parameter toPath:        The full path to redirect to.
    */
  public func addRedirect(pathPattern: String, toPath: String) {
    self.addRoute(pathPattern, method: "GET", handler: {
      request, responseHandler in
      var response = Response()
      response.code = 302
      response.headers["location"] = toPath
      response.appendString("You are being redirected")
      responseHandler(response)
    }, description: "Redirect")
  }
  
  /**
    This method adds a route with a block.

    - parameter pathPattern:   The pattern for the route.
    - parameter handler:       The block that will handle the request.
    - parameter description:   The description of the route implementation.
    - parameter controller:    The controller that will handle the request.
    - parameter actionName:    The name of the action that will handle the request.
    */
  public func addRoute(pathPattern: String, method: String, handler: Connection.RequestHandler, description: String, controller: ControllerType.Type? = nil, actionName: String? = nil) {
    var fullPattern = self.currentPathPrefix
    if !pathPattern.isEmpty {
      fullPattern += "/" + pathPattern
    }
    var route = Route(pathPattern: fullPattern, method: method, handler: handler, description: description)
    route.controller = controller ?? currentController
    route.actionName = actionName
    self.routes.append(route)
  }
  
  /**
    This method adds a route for a controller action.

    - parameter pathPattern:    The pattern for the route.
    - parameter method:         The HTTP method for the route.
    - parameter actionName:     The name of the action, for use in debugging
                                and looking up routes by name.
    - parameter action          The body of the action.
    */
  public func addRoute<T: ControllerType>(pathPattern: String, method: String, actionName: String, action: (T)->()->()) {
    let description = NSString(format: "%@#%@", T.name, actionName) as String
    let filters = self.currentFilters
    let handler: Connection.RequestHandler = {
      (request: Request, callback: Connection.ResponseCallback) in
      let controller = T(request: request, actionName: actionName, callback: callback)
      for filter in filters {
        if !filter(controller)() {
          return
        }
      }
      action(controller)()
    }
    addRoute(pathPattern, method: method, handler: handler, description: description, controller: T.self, actionName: actionName)
  }
  
  /**
    This method adds a route with a block.

    - parameter pathPattern:   The pattern for the route.
    - parameter method:        The HTTP method for the route.
    - parameter handler:       The block that will handle the request.
  */
  public func addRoute(pathPattern: String, method: String, handler: Connection.RequestHandler) {
    self.addRoute(pathPattern, method: method, handler: handler, description: "custom block")
  }
  
  /**
    This method adds a route that will be handled by a controller.

    - parameter pathPattern:   The pattern for the route.
    - parameter method:        The HTTP method for the route.
    - parameter controller:    The controller that will handle the requests.
    - parameter actionName:    The name of the action in the controller.
    */
  @available(*, deprecated) public func addRoute(pathPattern: String, method: String, controller controllerType: Controller.Type, actionName: String) {
    let description = NSString(format: "%@#%@", controllerType.name, actionName)
    let handler = {
      (request: Request, callback: Connection.ResponseCallback) -> () in
      let controller = controllerType(request: request, actionName: actionName, callback: callback)
      controller.action.run(controller)
    }
    self.addRoute(pathPattern, method: method, handler: handler, description: description as String, controller: controllerType, actionName: actionName)
  }
  
  /**
    This method adds a route that will be handled by the current controller.
    
    - parameter pathPattern:   The pattern for the route.
    - parameter method:        The HTTP method for the route.
    - parameter actionName:    The name of the action in the controller.
    */
  @available(*, deprecated) public func addRoute(pathPattern: String, method: String, actionName: String) {
    if let type = self.currentController as? Controller.Type {
      self.addRoute(pathPattern, method: method, controller: type, actionName: actionName)
    }
  }
  
  /**
    This method adds restful routes.
  
    The restful actions are index, new, create, edit, update, and destroy.
  
    - parameter only:     The actions to add. If this is empty, it will add all
                          the actions.
    - parameter except:   The actions to skip.
  */
  @available(*, deprecated) public func addRestfulRoutes(only only: [String] = [], except: [String] = []) {
    var actions = (only.isEmpty ? ["index", "new", "create", "show", "edit", "update", "destroy"] : only)
    
    for action in except {
      if let index = actions.indexOf(action) {
        actions.removeAtIndex(index)
      }
    }
    
    for action in actions {
      var route = ""
      var method = "GET"
      
      switch action {
      case "create", "update", "destroy":
        method = "POST"
      default:
        break
      }
      
      switch(action) {
      case "show", "update":
        route = ":id"
      case "edit":
        route = ":id/edit"
      case "destroy":
        route = ":id/destroy"
      case "new":
        route = "new"
      default:
        break
      }
      self.addRoute(route, method: method, actionName: action)
    }
  }
  
  /**
    This method prints information about all of the routes.
    */
  public func printRoutes() {
    for route in self.routes {
      NSLog("%@", route.fullDescription())
    }
  }
  
  //MARK: - Handling Requests
  
  /**
    This method handles a request using the first matching route in the route
    set.

    If there is no matching route, it will give a 404 response.

    - parameter request:   The request that we should handle.
    - parameter callback:  The callback that we should give the response to.
    */
  public func handleRequest(request: Request, callback: Connection.ResponseCallback) {
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
  
  /**
    This method generates a set of routes for static assets.
    
    The handlers for this will read the file contents for each file from the
    disk and serve it out as the response. The local paths for the assets will
    be relative to the application's root path, which defaults to the directory
    containing the executable.
    
    - parameter prefix:         The prefix that we append to all the static asset
                                URLs.
    - parameter localPrefix:    The prefix that we append to all of the paths
                                for the assets on disk.
    - parameter assets:         The names of the asset files.
  */
  public func staticAssets(prefix prefix: String, localPrefix: String, assets: [String]) {
    for assetName in assets {
      let path = "\(prefix)/\(assetName)"
      let localPath = "\(localPrefix)/\(assetName)"
      self.addRoute(path, method: "GET") {
        (request, callback) -> () in
        
        let fullPath = Application.sharedApplication().rootPath() + "/\(localPath)"
        
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
  
  //MARK: - Generating URLs
  
  /**
    This method generates a path using our route set.

    - parameter controller:     The name of the controller that the link is to.
    - parameter actionName:     The name of the action.
    - parameter parameters:     The parameters to interpolate into the route.
    - parameter domain:         The domain to use for a full URL. If this is
                                omitted, this will just give the path rather
                                than a URL.
    - parameter https:          Whether the URL should use the https protocol.
                                If the domain is omitted, this value will be
                                ignored.
    - returns:                  The path, if we could match it up.
    */
  public func pathFor(controllerName: String, actionName: String, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    var matchingPath: String? = nil
    for route in self.routes {
      if route.controller != nil && route.controller!.name == controllerName &&
      route.actionName != nil && route.actionName! == actionName {
        var path = route.pathPattern
        var hasQuery = false
        for (key, value) in parameters {
          if let range = path.rangeOfString(":" + key, options: [], range: nil, locale: nil) {
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
        matchingPath = path
        break
      }
    }
    if matchingPath != nil && domain != nil {
      let httpProtocol = https ? "https" : "http"
      matchingPath = "\(httpProtocol)://\(domain!)\(matchingPath!)"
    }
    return matchingPath
  }
}