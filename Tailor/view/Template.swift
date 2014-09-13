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
  private var buffer = NSMutableString()
  
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
  func tag(name: String, attributes: [String:String] = [:], with contents: ()->() = {}) -> () {
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
}