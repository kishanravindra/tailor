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
  let body: (Template, [String: Any])->String
  
  /**
    This method creates a template.

    :param: body    The closure for the body.
    */
  required init(body: (Template, [String: Any])->String){
    self.body = body
  }
  
  //MARK: - Body
  
  /**
    This method generates the body using the template.

    :param: parameters  The parameters to pass to the template.
    :returns: The body.
    */
  func generate(parameters: [String: Any]) -> String {
    return self.body(self, parameters)
  }
  
  //MARK: - Helpers
  
  /**
    This method adds generates an HTML tag.
  
    :param: name          The name of the element.
    :param: attributes    Additional attributes for the tag.
    :param: with          A closure providing the contents of the tag.
    :returns:             The tag HTML.
    */
  func tag(name: String, attributes: [String:String] = [:], with contents: ()->String = {""}) -> String {
    var text = ""
    var openingTag = "<\(name)"
    
    for (key,value) in attributes {
      openingTag += " \(key)=\"\(value)\""
    }
    openingTag += ">"
    return openingTag + contents() + "</\(name)>"
  }
}