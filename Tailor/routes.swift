func defineRoutes() {
  let routes = Application.sharedApplication().routeSet
  routes.addRoute("/path", handler: {
    (request, callback) in
    var response = Response()
    response.appendString("Result")
    callback(response)
  })
  
  routes.addRoute("/items", handler: {
    (request, callback) in
    var response = Response()
    response.appendString("[1,2]")
    callback(response)
  })
  
  routes.addRoute("/item/:id", handler: {
    (request, callback) in
    var response = Response()
    let id = request.requestParameters["id"]!
    response.appendString("Item \(id)")
    callback(response)
  })
}