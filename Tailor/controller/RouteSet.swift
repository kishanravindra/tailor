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
    /**
      The path for the route.
      */
    public let path: RoutePath
    
    /**
      The pattern for the path.
    
      This has been deprecated in favor of the path variable.
      */
    @available(*, deprecated, message="Use the path instead") public var pathPattern: String { return path.pathPattern }
    
    /**
      The method for the HTTP request.
    
      This has been deprecated in favor of the new path variable.
      */
    @available(*, deprecated, message="Use the path instead") public var method: String { return path.methodName }
    
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
    
      This method has been deprecated in favor of the version that takes a path
      enum.

      - parameter pathPattern:    The pattern for the path.
      - parameter method:         The HTTP method.
      - parameter handler:        The response handler.
      - parameter description:    The description for the route.
      */
    @available(*, deprecated, message="This has been deprecated in favor of the version that takes a path") public init(pathPattern: String, method: String, handler: Connection.RequestHandler, description: String) {
      let path = RoutePath.build(method, pathPattern: pathPattern) ?? RoutePath.Get(pathPattern)
      self.init(path: path, handler: handler, description: description)
    }
    
    /**
      This method initializes a route.
      
      - parameter path:           The path.
      - parameter handler:        The response handler.
      - parameter description:    The description for the route.
      */
    public init(path: RoutePath, handler: Connection.RequestHandler, description: String) {
      self.path = path
      self.handler = handler
      self.description = description
      
      let parameterPattern = try! NSRegularExpression(pattern: ":[\\w]+", options: [])
      
      var parameterNames : [String] = []
      
      parameterPattern.enumerateMatchesInString(path.pathPattern, options: [], range: NSMakeRange(0, path.pathPattern.characters.count), usingBlock: {
        (match, _, _) in
        guard let match = match else { return }
        let range = Range<String.Index>(start: advance(path.pathPattern.startIndex, match.range.location + 1), end: advance(path.pathPattern.startIndex, match.range.location + match.range.length))
        parameterNames.append(path.pathPattern.substringWithRange(range))
      })
      
      self.pathParameters = parameterNames
      
      let filteredPathPattern = NSMutableString(string: path.pathPattern)
      
      parameterPattern.replaceMatchesInString(filteredPathPattern, options: [], range: NSMakeRange(0, path.pathPattern.characters.count), withTemplate: "([^/]*)")
      
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
      return NSString(format: "%@ %@", self.path.description, self.description) as String
    }
    
    //MARK: - Request Handling
    
    /**
      This method determines if this route can handle a request.

      - parameter request:    The request to check.
      - returns:              Whether the route can handle the request.
      */
    public func canHandleRequest(request: Request) -> Bool {
      let path = request.path.stringByRemovingPercentEncoding ?? request.path
      let range = NSRange(location: 0, length: path.characters.count)
      let match = self.regex?.firstMatchInString(path, options: [], range: range)
      return match != nil && request.method == self.path.methodName
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
  
  /**
    This enum represents a path in a route.
  
    The enum cases represent the HTTP verbs, and each one takes a string for the
    path.
    */
  public enum RoutePath: Equatable, CustomStringConvertible {
    /** A GET request */
    case Get(String)
    
    /** A POST request */
    case Post(String)
    
    /** A PUT request. */
    case Put(String)
    
    /** A PATCH request. */
    case Patch(String)
    
    /** A DELETE request. */
    case Delete(String)
    
    /** A TRACE request. */
    case Trace(String)
    
    /** A HEAD request. */
    case Head(String)
    
    /** An OPTIONS request. */
    case Options(String)
    
    /** A CONNECT request. */
    case Connect(String)
    
    /**
      This method builds a route path dynamically.
    
      If the method name is not available, this will return nil. The method name
      must be in all caps.

      - parameter methodName:   The name of the method.
      - parameter pathPattern:  The path
      - returns:                The route path.
      */
    public static func build(methodName: String, pathPattern: String) -> RoutePath? {
      switch(methodName) {
      case "GET": return .Get(pathPattern)
      case "POST": return .Post(pathPattern)
      case "PUT": return .Put(pathPattern)
      case "PATCH": return .Patch(pathPattern)
      case "DELETE": return .Delete(pathPattern)
      case "OPTIONS": return .Options(pathPattern)
      case "HEAD": return .Head(pathPattern)
      case "TRACE": return .Trace(pathPattern)
      case "CONNECT": return .Connect(pathPattern)
      default: return nil
      }
    }
    
    /**
      This method extracts the path pattern from the route.
      */
    public var pathPattern: String {
      switch(self) {
      case let Get(pathPattern): return pathPattern
      case let Post(pathPattern): return pathPattern
      case let Put(pathPattern): return pathPattern
      case let Patch(pathPattern): return pathPattern
      case let Delete(pathPattern): return pathPattern
      case let Options(pathPattern): return pathPattern
      case let Head(pathPattern): return pathPattern
      case let Trace(pathPattern): return pathPattern
      case let Connect(pathPattern): return pathPattern
      }
    }
    
    /**
      This method extracts the method name from the route.
      This will be in all caps.
      */
    public var methodName: String {
      switch(self) {
      case Get: return "GET"
      case Post: return "POST"
      case Put: return "PUT"
      case Patch: return "PATCH"
      case Delete: return "DELETE"
      case Options: return "OPTIONS"
      case Head: return "HEAD"
      case Trace: return "TRACE"
      case Connect: return "CONNECT"
      }
    }
    
    /**
      This method gets a description of this route, which will contain the
      method name and the path pattern.
      */
    public var description: String {
      return "\(methodName) \(pathPattern)"
    }
    
    /**
      This method builds a new route path that uses this route path's HTTP
      method and a different path.

      - parameter pathPattern:    The pattern for the new path.
      - returns:                  The new path.
      */
    public func withPathPattern(pathPattern: String) -> RoutePath {
      switch(self) {
      case Get: return Get(pathPattern)
      case Post: return Post(pathPattern)
      case Put: return Put(pathPattern)
      case Patch: return Patch(pathPattern)
      case Delete: return Delete(pathPattern)
      case Options: return Options(pathPattern)
      case Head: return Head(pathPattern)
      case Trace: return Trace(pathPattern)
      case Connect: return Connect(pathPattern)
      }
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
  private var currentFilters: [RequestFilterType] = [CsrfFilter()]
  
  /**
    This method creates an empty route set.
    */
  public init() {
    
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
  
    This allows you to add filters that will be run before the controller
    action. The filters take in a controller and return a function that will
    return a boolean. The boolean return value should indicate whether the
    request passed the filter. Filters can check if a request has all the
    necessary parameters, or if the parameters are consistent with other parts
    of the state of the system, or anything else that you want to be a reusable
    check. 
  
    After the controller action has run, the filters' post-processing calls will
    be run, in reverse order. This allows filters to add additional header
    fields based on the response data.
  
    These filters will only be run on routes that are handled by controllers.

    As soon as one of the filters says to stop, we will stop all pre-processing,
    and will not call the controller action at all. We will do post-processing
    with the filters, starting with the last filter that ran.
  
    The filters will only be applied to controller actions.

    - parameter path:       A segment of a path that will be applied to the
                            beginning of the routes. There will be a slash added
                            to the beginning of this segment.
    - parameter filters:    The filters to run.
    - parameter filter:     The filter to run. If both this and filters are
                            provided, this filter will be run after the one in
                            the filters list.
    - parameter block:      A block that will add the specific routes.
    */
  public func withScope(path path: String? = nil, filters: [RequestFilterType] = [], filter: RequestFilterType? = nil, @noescape block: Void->Void) {
    let oldPrefix = self.currentPathPrefix
    if let path = path {
      self.currentPathPrefix += "/" + path
    }
    let oldFilters = currentFilters
    var newFilters = currentFilters + filters
    if let filter = filter { newFilters.append(filter) }
    self.currentFilters = newFilters
    block()
    self.currentFilters = oldFilters
    self.currentPathPrefix = oldPrefix
  }
  
  /**
    This method removes a request filter from the list of filters for a section
    of the route set.

    The filter provided will not be applied to any routes added in the block.

    - parameter filter:   The filter we do not want to apply
    - parameter block:    The block for adding the routes.
    */
  public func withoutFilter<FilterType: RequestFilterType where FilterType: Equatable>(filter: FilterType, @noescape block: Void->Void) {
    let oldFilters = currentFilters
    self.currentFilters = oldFilters.filter {
      if let castValue = $0 as? FilterType {
        return castValue != filter
      }
      else {
        return true
      }
    }
    block()
    self.currentFilters = oldFilters
  }
  
  /**
    This method sets up a redirect from one path to the other.

    - parameter pathPattern:   The regular expression for the incoming path.
    - parameter toPath:        The full path to redirect to.
    */
  public func addRedirect(pathPattern: String, toPath: String) {
    self.addRoute(.Get(pathPattern), handler: {
      request, responseHandler in
      var response = Response()
      response.responseCode = .SeeOther
      response.headers["location"] = toPath
      response.appendString("You are being redirected")
      responseHandler(response)
    }, description: "Redirect")
  }
  
  /**
    This method adds a route with a block.
  
    This method has been deprecated in favor of the version with a path enum.

    - parameter pathPattern:   The pattern for the route.
    - parameter handler:       The block that will handle the request.
    - parameter description:   The description of the route implementation.
    - parameter controller:    The controller that will handle the request.
    - parameter actionName:    The name of the action that will handle the request.
    */
  @available(*, deprecated, message="Use the version that takes a path enum instead") public func addRoute(pathPattern: String, method: String, handler: Connection.RequestHandler, description: String, controller: ControllerType.Type? = nil, actionName: String? = nil) {
    let path = RoutePath.build(method, pathPattern: pathPattern) ?? .Get(pathPattern)
    self.addRoute(path, handler: handler, description: description, controller: controller, actionName: actionName)
  }
  
  /**
    This method adds a route with a block.
    
    - parameter path:           The path for the route.
    - parameter description:    The description of the route implementation.
    - parameter controller:     The controller that will handle the request.
    - parameter actionName:     The name of the action that will handle the request.
  */
  public func addRoute(path: RoutePath, handler: Connection.RequestHandler, description: String, controller: ControllerType.Type? = nil, actionName: String? = nil) {
    var fullPattern = self.currentPathPrefix
    let pathPattern = path.pathPattern
    if !pathPattern.isEmpty {
      fullPattern += "/" + pathPattern
    }
    let fullPath = path.withPathPattern(fullPattern)
    var route = Route(path: fullPath, handler: handler, description: description)
    route.controller = controller ?? currentController
    route.actionName = actionName
    self.routes.append(route)
  }
  
  /**
    This method adds a route for a controller action.
  
    This method has been deprecated in favor of the version that takes a path
    enum.

    - parameter pathPattern:    The pattern for the route.
    - parameter method:         The HTTP method for the route.
    - parameter actionName:     The name of the action, for use in debugging
                                and looking up routes by name.
    - parameter action          The body of the action.
    */
  @available(*, deprecated, message="Use the version that takes a path enum instead") public func addRoute<T: ControllerType>(pathPattern: String, method: String, actionName: String, action: (T)->()->()) {
    let path = RoutePath.build(method, pathPattern: pathPattern) ?? .Get(pathPattern)
    self.route(path, to: action, name: actionName)
  }
  
  
  /**
    This method adds a route for a controller action.
    
    - parameter path:           The path for the route.
    - parameter actionName:     The name of the action, for use in debugging
                                and looking up routes by name.
    - parameter action          The body of the action.
    */
  public func route<T: ControllerType>(path: RoutePath, to action: (T)->()->(), name actionName: String) {
    let description = NSString(format: "%@#%@", T.name, actionName) as String
    let filters = self.currentFilters
    let handler: Connection.RequestHandler = {
      (request: Request, callback: Connection.ResponseCallback) in
      self.respondWithController(action, actionName: actionName, request: request, response: Response(), filters: filters, filterIndex: 0, inPostProcessing: false, callback: callback)
    }
    addRoute(path, handler: handler, description: description, controller: T.self, actionName: actionName)
  }
  
  /**
    This method adds a route with a block.
  
    This method has been deprecated in favor of the version that takes a path
    enum.

    - parameter pathPattern:   The pattern for the route.
    - parameter method:        The HTTP method for the route.
    - parameter handler:       The block that will handle the request.
  */
  @available(*, deprecated, message="Use the version that takes a path enum instead") public func addRoute(pathPattern: String, method: String, handler: Connection.RequestHandler) {
    let path = RoutePath.build(method, pathPattern: pathPattern) ?? .Get(pathPattern)
    self.addRoute(path, handler: handler)
  }
  
  /**
    This method adds a route with a block.
  
    - parameter path:           The path for the route.
    - parameter handler:        The block that will handle the request.
    */
  public func addRoute(path: RoutePath, handler: Connection.RequestHandler) {
    self.addRoute(path, handler: handler, description: "custom block")
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
      let controller = controllerType.init(request: request, response: Response(), actionName: actionName, callback: callback)
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
    This method adds routes from several controllers.

    - parameters: controllers   The controller whose routes we are adding.
    */
  public func addControllerRoutes(controllers: ControllerType.Type...) {
    for controller in controllers {
      controller.defineRoutes(self)
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
    This method responds with a controller, wrapping its response in filters.
  
    - parameter action:             The action to call on the controller.
    - parameter actionName:         The name of the action.
    - parameter request:            The request that we are responding to.
    - parameter response:           The response so far.
    - parameter filters:            The filters that we are calling.
    - parameter filterIndex:        The index of the current filter in the list.
    - parameter inPostProcessing:   Whether we have already called the
                                    controller and are now doing the post
                                    processing on the filters.
    */
  private func respondWithController<SpecificType: ControllerType>(action: (SpecificType)->()->(), actionName: String, request: Request, response: Response, filters: [RequestFilterType], filterIndex: Int, inPostProcessing: Bool, callback: (Response)->Void) {
    if inPostProcessing {
      if filterIndex >= filters.startIndex {
        filters[filterIndex].postProcess(request, response: response) {
          newResponse in
          self.respondWithController(action, actionName: actionName, request: request, response: newResponse, filters: filters, filterIndex: filterIndex - 1, inPostProcessing: inPostProcessing, callback: callback)
        }
      }
      else {
        callback(response)
      }
    }
    else {
      if filterIndex < filters.endIndex {
        filters[filterIndex].preProcess(request, response: response) {
          newRequest, newResponse, stop in
          if stop {
            NSLog("Processing stopped due to filter: %@", String(filters[filterIndex]))
            self.respondWithController(action, actionName: actionName, request: newRequest, response: newResponse, filters: filters, filterIndex: filterIndex, inPostProcessing: true, callback: callback)
          }
          else {
            self.respondWithController(action, actionName: actionName, request: newRequest, response: newResponse, filters: filters, filterIndex: filterIndex + 1, inPostProcessing: inPostProcessing, callback: callback)
          }
        }
      }
      else {
        let controller = SpecificType(request: request, response: response, actionName: actionName) {
          newResponse in
          self.respondWithController(action, actionName: actionName, request: request, response: newResponse, filters: filters, filterIndex: filters.endIndex - 1, inPostProcessing: true, callback: callback)
        }
        action(controller)()
      }
    }
  }
  /**
    This method determines if this route set can handle a request.

    - parameter request:    The request that we're handling.
    - returns:              Whether we can handle it.
    */
  public func canHandleRequest(request: Request) -> Bool {
    return !routes.filter { $0.canHandleRequest(request) }.isEmpty
  }
  
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
    response.responseCode = .NotFound
    response.appendString("File Not Found")
    callback(response)
  }
  
  /**
    This method generates a set of routes for static assets.
    
    The handlers for this will read the file contents for each file from the
    disk and serve it out as the response. The local paths for the assets will
    be relative to the application's root path, which defaults to the directory
    containing the executable.
  
    The assets will be given an ETag header with an MD5 hash of their contents.
    If the client provides that tag in a request, this will return a
    not-modified response.
    
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
      self.addRoute(.Get(path)) {
        (request, callback) -> () in
        
        let fullPath = Application.sharedApplication().rootPath() + "/\(localPath)"
        
        let mimeType: String
        if let contents = NSFileManager.defaultManager().contentsAtPath(fullPath) {
          if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (fullPath as NSString).pathExtension, nil)?.takeRetainedValue(),
            let type = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
              mimeType = type as String
          }
          else {
            mimeType = "text/plain"
          }
          
          let eTag = contents.md5Hash
          var response = Response()
          response.headers["ETag"] = eTag
          response.headers["Content-Type"] = mimeType
          if request.headers["If-None-Match"] == eTag {
            response.responseCode = .NotModified
          }
          else {
            response.responseCode = .Ok
            response.appendData(contents)
          }
          callback(response)
        }
        else {
          var response = Response()
          response.responseCode = .NotFound
          callback(response)
        }
      }
    }
  }
  
  //MARK: - Generating URLs
  
  /**
    This method generates a path using our route set.
  
    This method has been deprecated in favor of the one that uses a controller
    type.

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
  @available(*, deprecated, message="Use a controller type instead") public func pathFor(controllerName: String, actionName: String, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    var matchingPath: String? = nil
    for route in self.routes {
      guard let routeController = route.controller, let routeAction = route.actionName else { continue }
      if routeController.name == controllerName && routeAction == actionName {
        var path = route.path.pathPattern
        var hasQuery = false
        for (key, value) in parameters {
          if let range = path.rangeOfString(":" + key, options: [], range: nil, locale: nil) {
            path = path.stringByReplacingCharactersInRange(range, withString: value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) ?? "")
          }
          else {
            if hasQuery {
              path += "&"
            }
            else {
              path += "?"
              hasQuery = true
            }
            path += key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) ?? ""
            path += "="
            path += value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) ?? ""
          }
        }
        matchingPath = path
        break
      }
    }
    
    if let path = matchingPath, let domain = domain {
      let httpProtocol = https ? "https" : "http"
      matchingPath = "\(httpProtocol)://\(domain)\(path)"
    }
    return matchingPath

  }
  
  /**
    This method generates a path using our route set.
    
    - parameter controller:     The type of the controller that the link is to.
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
  public func pathFor(controllerType: ControllerType.Type, actionName: String, parameters: [String:String] = [:], domain: String? = nil, https: Bool = true) -> String? {
    var matchingPath: String? = nil
    for route in self.routes {
      guard let routeController = route.controller, let routeAction = route.actionName else { continue }
      if routeController == controllerType && routeAction == actionName {
        var path = route.path.pathPattern
        var hasQuery = false
        for (key, value) in parameters {
          if let range = path.rangeOfString(":" + key, options: [], range: nil, locale: nil) {
            path = path.stringByReplacingCharactersInRange(range, withString: value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) ?? "")
          }
          else {
            if hasQuery {
              path += "&"
            }
            else {
              path += "?"
              hasQuery = true
            }
            path += key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) ?? ""
            path += "="
            path += value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet()) ?? ""
          }
        }
        matchingPath = path
        break
      }
    }
    
    if let path = matchingPath, let domain = domain {
      let httpProtocol = https ? "https" : "http"
      matchingPath = "\(httpProtocol)://\(domain)\(path)"
    }
    return matchingPath
  }
  
  //MARK: - Shared Routes
  
  /**
    This method loads the shared route set.
  
    This will build an empty route set, give it to the routeBuilder to
    populate the routes, and then set that as the shared route set.

    - parameter routeBuilder:   A function that will populate the routes.
    */
  public static func load(@noescape routeBuilder: (inout RouteSet) -> ()) {
    var routes = RouteSet()
    routeBuilder(&routes)
    SHARED_ROUTE_SET = routes
  }
  
  /**
    This method gets the shared route set.
    */
  public static func shared() -> RouteSet {
    return SHARED_ROUTE_SET
  }
}

private var SHARED_ROUTE_SET = RouteSet()

/**
  This method determines if two route paths are equal.

  Route paths are equal when they have the same method and path pattern.

  - parameter lhs:    The left-hand side of the operator
  - parameter rhs:    The right-hand side of the operator
  - returns:          Whether the two paths are equal.
  */
public func ==(lhs: RouteSet.RoutePath, rhs: RouteSet.RoutePath) -> Bool {
  return lhs.methodName == rhs.methodName && lhs.pathPattern == rhs.pathPattern
}