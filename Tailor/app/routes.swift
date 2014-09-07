/** The routes for the Haberdashery application. */
let HaberdasheryRouteSet = {
  ()->RouteSet in
  
  let routes = RouteSet()
  
  routes.addRoute("/path", handler: {
    (request, callback) in
    var response = Response()
    response.appendString("Result")
    callback(response)
  })
    
  routes.withPrefix("/items", controller: ItemsController(), {
    routes.addRoute("", action: "index")
    routes.addRoute("/:id", action: "show")
  })
  
  return routes
}()