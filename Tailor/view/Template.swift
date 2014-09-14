import Foundation

/**
  This class provides a template for generating a response to a request.
  */
class Template {
  /**
    A closure providing the body of the response.

    The first argument is the template itself, and the second argument is a
    hash of parameters from the controller.
    */
  let body: (Template, [String: Any])->()
  
  /** The buffer that we use to build our result. */
  let buffer = NSMutableString()
  
  /** The controller that is requesting the rendering. */
  var controller: Controller?
  
  /**
    This method creates a template.

    :param: body    The closure for the body.
    */
  required init(body: (Template, [String: Any])->()){
    self.body = body
  }
  
  //MARK: - Body
  
  /**
    This method generates the body using the template.

    :param: parameters  The parameters to pass to the template.
    :returns: The body.
    */
  func generate(parameters: [String: Any]) -> String {
    self.body(self, parameters)
    return self.buffer
  }
  
  //MARK: - Helpers
  
  /**
    This method appends text to our buffer.

    :param: text     The text to add.
    */
  func text(text: String) {
    self.buffer.appendString(text)
  }
  
  /**
    This method adds an HTML tag.
  
    :param: name          The name of the element.
    :param: attributes    Additional attributes for the tag.
    :param: with          A closure that adds the contents of the tag.
    */
  func tag(name: String, _ attributes: [String:String], with contents: ()->() = {}) -> () {
    var text = ""
    var openingTag = "<\(name)"
    
    for (key,value) in attributes {
      openingTag += " \(key)=\"\(value)\""
    }
    openingTag += ">"
    buffer.appendString(openingTag)
    contents()
    buffer.appendString("</\(name)>")
  }
  
  /**
    This method adds an HTML tag.
  
    This is just a wrapper around the version with explicit attributes, but
    using default values for that parameter causes problems with having a
    trailing closure.

    :param: name          The name of the element.
    :param: contents      A closure that adds the contents of the tag.
    */
  func tag(name: String, contents: ()->() = {}) -> () {
    self.tag(name, [:], with: contents)
  }
  
  /**
    This method adds an HTML tag.
    
    :param: name          The name of the element.
    :param: attributes    Additional attributes for the tag.
    :param: text          The text for the tag.
    */
  func tag(name: String, attributes: [String:String] = [:], text: String) -> () {
    self.tag(name, attributes) { self.text(text) }
  }
  
  /**
    This method gets the URL for a route.

    :param: controller  The controller to link to. This will default to the
                        current controller.
    :param: action      The action to link to.
    :param: parameters  Additional parameters for the path.
    :reutrns:           The path
    */
  func urlFor(controller: Controller? = nil, action: String? = nil, parameters: [String:String] = [:]) -> String? {
    return SHARED_APPLICATION.routeSet.urlFor(
      controller?.name ?? self.controller?.name ?? "",
      action: action ?? self.controller?.action ?? "",
      parameters: parameters
    )
  }
  
  /**
    This method adds a tag for linking to a path.
  
    :param: controller  The controller to link to. This will default to the
                        current controller.
    :param: action      The action to link to.
    :param: parameters  Additional parameters for the path.
    :param: attributes  Additional attributes for the tag.
    :param: with        A closure that adds the contents of the link.
    */
  func link(controller: Controller? = nil, action: String? = nil, parameters: [String:String] = [:], attributes: [String:String] = [:], with contents: ()->()={}) {
    var mergedAttributes = attributes
    mergedAttributes["href"] = self.urlFor(controller: controller,
      action: action, parameters: parameters) ?? ""
    self.tag("a", mergedAttributes, with: contents)
  }
}