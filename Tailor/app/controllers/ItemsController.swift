import Foundation

/**
  This class provides a controller for managing actions.
  */
class ItemsController : Controller {
  override required init(){
    super.init()
    self.name = "ItemsController"
    
    self.actions["index"] = {
      (request,callback) in
      var response = Response()
      response.appendString("[1,2]")
      callback(response)
    }
    
    self.actions["show"] = {
      (request,callback) in
      var response = Response()
      var id = request.requestParameters["id"]
      response.appendString("{id: \(id)}")
      callback(response)
    }
  }
}