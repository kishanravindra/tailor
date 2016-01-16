import Tailor
import Foundation

RouteSet.load {
  (inout routes: RouteSet) in
  routes.addRoute(.Get("")) {
    request, callback in
    var response = Response()
    callback(response)
  }
  routes.addRoute(.Get(":name")) {
    request, callback in
    var response = Response()
    let name: String = request.params["name"]
    response.appendString("Hello, \(name)")
    callback(response)
  }
}
ServerTask.runTask()