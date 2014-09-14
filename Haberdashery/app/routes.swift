/** The routes for the Haberdashery application. */
let HaberdasheryRouteSet = {
  ()->RouteSet in
  
  let routes = RouteSet()
  
  routes.withPrefix("hats", controller: HatsController<Hat>.self, {
    routes.addRoute("", method: "GET", action: "index")
    routes.addRoute("", method: "POST", action: "create")
    routes.addRoute("new", method: "GET", action: "new")
    routes.addRoute(":id", method: "GET", action: "show")
    routes.addRoute(":id/edit", method: "GET", action: "edit")
    routes.addRoute(":id", method: "POST", action: "update")
  })
  
  routes.staticAssets(prefix: "assets", localPrefix: "assets", assets: [
    "application.css"
  ])
  
  return routes
}()