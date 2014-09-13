import Foundation

/**
  This class provides a controller for listing and managing hats.
*/
class HatsController : Controller {
  override required init(){
    super.init()
    self.name = "HatsController"
    self.actions["index"] = self.index
  }
  
  //MARK: - Actions
  
  /**
    This action provides a listing of hats.
  
    :param: request   The request from the client.
    :param: callback  The callback to give the response to.
  */
  func index(request : Request, callback: Server.ResponseCallback) {
    let hats = Hat.find()
    self.respondWith(HatIndexTemplate, callback: callback, parameters: [
      "hats": Hat.find(),
      "foo": "bar"
    ])
  }
}