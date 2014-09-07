import Foundation

/**
  This class provides a controller for managing actions.
  */
class ItemsController : Controller {
  override required init(){
    super.init()
    self.name = "ItemsController"
    self.actions["index"] = self.index
    self.actions["show"] = self.show
  }
  
  //MARK: - Actions
  
  /**
    This action provides a listing of items.
  
    :param: request   The request from the client.
    :param: callback  The callback to give the response to.
    */
  func index(request : Request, callback: Server.ResponseCallback) {
    self.respondWith(ItemIndexTemplate, callback: callback)
  }
  
  /**
    This action provides a page for a single item.
  
    This expects the following request parameters:
  
    * id: The id of the item.

    :param: request   The request from the client.
    :param: callback  The callback to give the response to.
    */
  func show(request: Request, callback: Server.ResponseCallback) {
    let id = request.requestParameters["id"]?.toInt()
    self.respondWith(ItemShowTemplate, callback: callback, parameters: [
      "id": id!
    ])
  }
}