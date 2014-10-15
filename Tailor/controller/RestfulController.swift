/**
  This class provides a controller with restful actions for accessing a
  collection of records.
  */
public class RestfulController<RecordType: Record> : Controller {
  /** The templates that this controller has for its actions. */
  public var templates: [String: Template] = [:]
  
  /**
    This method initializes the controller.

    :param: request     The request that we are processing.
    :param: action      The action on the controller that we are executing.
    :param: callback    The callback to call with the response.
    */
  public required init(request: Request, action: String, callback: Server.ResponseCallback) {
    super.init(request: request, action: action, callback: callback)
  }
  
  //MARK: - Data
  
  /** The record that we are working on. */
  public func record() -> RecordType? {
    if let idString = request.requestParameters["id"] {
      if let id = idString.toInt() {
        let record = RecordType.find(id)
        return record == nil ? nil : record! as? RecordType
      }
    }
    else {
      return RecordType()
    }
    return nil
  }
  
  //MARK: - Actions
  
  /**
    This method runs the current action on the controller.
    */
  public override func respond() {
    switch(action) {
      case "index": self.index()
      case "show": self.show()
      case "new": self.form()
      case "create": self.processForm()
      case "edit": self.form()
      case "update": self.processForm()
      default: super.respond()
    }
  }
  
  /**
    This action provides a listing of records.
    */
  public func index() {
    let records =  RecordType.find() as [RecordType]
    if let template = self.templates["index"] {
      self.respondWith(template, parameters: [
        "records": records
      ])
    }
  }
  
  /**
    This action provides a page for showing information about a record.

    This expects these request parameters:
  
    * id: The id of the hat to show.
    */
  public func show() {
    if let record = record() {
      if let template = self.templates["show"] {
        self.respondWith(template, parameters: [
          "record": record
        ])
      }
      else {
        self.render404()
      }
    }
    else {
      self.render404()
    }
  }
  
  /**
    This action provides a form for creating or editing a record.
  
    This can take the following parameters:
  
    * id:     The id of the record to edit.
    */
  public func form() {
    if let record = record() {
      if let template = self.templates["form"] {
        self.respondWith(template, parameters: [
          "record": record
        ])
      }
    }
    else {
      self.render404()
    }
  }
  
  /**
    This method provides the shared logic for creating or updating a record.
  
    This can take the following parameters:
  
    * id:             The id of the record to update, if we are updating.
    * Additional keys as appropriate for the record type.
  */
  public func processForm() {
    if let record = self.record() {
      self.setAttributesOnRecord(record, parameters: request.requestParameters)
      if record.save() {
        let path = Application.sharedApplication().routeSet.urlFor(self.name, action: "index") ?? "/"
        self.redirectTo(path)
      }
      else {
        if let template = self.templates["form"] {
          self.respondWith(template, parameters: [
            "record": record
          ])
        }
        else {
          self.render404()
        }
      }
    }
    else {
      render404()
    }
  }
  
  /**
    This method updates the fields on a record based on the request parameters.
    
    This implementation does nothing. Subclasses are responsible for setting
    the attributes.

    :param: record      The record to update
    :param: parameters  The request parameters.
    */
  public func setAttributesOnRecord(record: RecordType, parameters: [String:String]) {
    
  }
}