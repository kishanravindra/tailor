import Foundation

/**
  This class provides a controller for listing and managing hats.
*/
class HatsController<RecordType> : RestfulController<Hat> {
  /**
    This method creates a controller to handle a request.
    
    :param: request   The request from the client.
    :param: action    The action that we are triggering.
    :param: callback  The callback to give the response to.
    */
  required init(request: Request, action: String, callback: Server.ResponseCallback) {
    super.init(request: request, action: action, callback: callback)
    
    self.layout = HaberdasheryLayout
    self.templates["index"] = HatIndexTemplate
    self.templates["show"] = HatShowTemplate
    self.templates["form"] = HatFormTemplate
  }
  
  /**
    This method sets the attributes on a hat from a form submission.
    
    :param: record        The hat
    :param: parameters    The request parameters.
    */
  override func setAttributesOnRecord(record: Hat, parameters: [String:String]) {
    if let brimSize = request.requestParameters["hat[brimSize]"]?.toInt() {
      record.brimSize = NSNumber(integer: brimSize)
    }
    
    record.color = request.requestParameters["hat[color]"]
    
    if record.validate() {
      session.setFlash("success", "Hat saved")
    }
  }
}