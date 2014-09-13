/** The routes for the Haberdashery application. */
let HaberdasheryRouteSet = {
  ()->RouteSet in
  
  let routes = RouteSet()
  
  routes.withPrefix("/hats", controller: HatsController(), {
    routes.addRoute("", action: "index")
  })
  
  return routes
}()