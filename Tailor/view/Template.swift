import Foundation

/**
  This class provides a template for generating a response to a request.
  */
public class Template {
  /** The buffer that we use to build our result. */
  public let buffer = NSMutableString()
  
  /** The controller that is requesting the rendering. */
  public let controller: Controller
  
  /** The other templates this template has rendered. */
  public private(set) var renderedTemplates: [Template] = []
  
  /**
    This method initializes a template.

    :param: controller    The controller that is rendering the template.
    */
  public init(controller: Controller) {
    self.controller = controller
  }
  
  //MARK: - Body
  
  /**
    This method generates the body using the template.
    
    :returns:           The body.
    */
  public func generate() -> String {
    self.buffer.setString("")
    self.body()
    return self.buffer as String
  }
  
  /**
    This method runs the body.

    This implementation does nothing. Subclasses must override this to provide
    the real rendered content.

    The content should be added to the buffer instance variable.
    */
  public func body() {
    
  }
  
  //MARK: - Helpers
  
  /**
    This method gets the prefix that is appended to the the keys for
    localization.

    This is only added to keys that start with a dot.
    */
  public var localizationPrefix: String {
    return reflect(self).summary.underscored()
  }

  /**
    This method localizes a key.

    This will use the localization from the template's controller.

    If the key begins with a dot, this will prepend the template's localization
    prefix.

    :param: key   The key to localize.
    :returns:     The localized text.
    */
  public func localize(key: String) -> String? {
    var fullKey = key
    if fullKey.hasPrefix(".") {
      fullKey = self.localizationPrefix + fullKey
    }
    return self.controller.localize(fullKey)
  }
  
  /**
    This method appends text to our buffer.
  
    It will HTML-sanitize the text automatically.

    :param: text      The text to add.
    :param: localize  Whether we should attempt to localize the text.
    */
  public func text(text: String, localize: Bool = true) {
    let localizedText = localize ? self.localize(text) ?? text : text
    let sanitizedText = HtmlSanitizer().sanitize(SanitizedText(stringLiteral: localizedText))
    self.addSanitizedText(sanitizedText)
  }
  
  /**
    This method appends text to our buffer without HTML-sanitizing it.

    Use this with caution, and only when you are certain the text is safe.

    :param: text    The text to add.
    */
  public func raw(text: String, localize: Bool = true) {
    let localizedText = localize ? self.controller.localize(text) ?? text : text
    self.addSanitizedText(HtmlSanitizer().accept(localizedText))
  }
  
  /**
    This method adds sanitized text to our buffer.

    It will check to make sure it is really HTML-sanitized, and sanitize it if
    necessary.

    :param: text    The text to add.
    */
  public func addSanitizedText(text: SanitizedText) {
    if !HtmlSanitizer.isSanitized(text) {
      self.addSanitizedText(HtmlSanitizer().sanitize(text))
    }
    else {
      self.buffer.appendString(text.text)
    }
  }
  
  /**
    This method adds an HTML tag.
  
    :param: name          The name of the element.
    :param: attributes    Additional attributes for the tag.
    :param: with          A closure that adds the contents of the tag.
    */
  public func tag(name: String, _ attributes: [String:String], with contents: ()->() = {}) -> () {
    var text = ""
    var openingTag = "<\(name)"
    
    for key in sorted(attributes.keys) {
      let value = attributes[key]!
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
  public func tag(name: String, with contents: ()->() = {}) -> () {
    self.tag(name, [:], with: contents)
  }
  
  /**
    This method adds an HTML tag.
    
    :param: name          The name of the element.
    :param: attributes    Additional attributes for the tag.
    :param: text          The text for the tag.
    */
  public func tag(name: String, text: String, attributes: [String:String] = [:]) -> () {
    self.tag(name, attributes) { self.text(text) }
  }
  
  /**
    This method gets the URL for a route.

    :param: controllerName  The controller to link to. This will default to the
                            current controller.
    :param: action          The action to link to.
    :param: parameters      Additional parameters for the path.
    :returns:               The path
    */
  public func urlFor(controllerName: String? = nil, action: String? = nil, parameters: [String:String] = [:]) -> String? {
    return self.controller.urlFor(controllerName: controllerName, action: action, parameters: parameters)
  }
  
  /**
    This method adds a tag for linking to a path.
  
    :param: controllerName  The controller to link to. This will default to the
                            current controller.
    :param: action          The action to link to.
    :param: parameters      Additional parameters for the path.
    :param: attributes      Additional attributes for the tag.
    :param: with            A closure that adds the contents of the link.
    */
  public func link(controllerName: String? = nil, action: String? = nil, parameters: [String:String] = [:], attributes: [String:String] = [:], with contents: ()->()={}) {
    var mergedAttributes = attributes
    mergedAttributes["href"] = self.urlFor(controllerName: controllerName,
      action: action, parameters: parameters) ?? ""
    self.tag("a", mergedAttributes, with: contents)
  }
  
  /**
    This method renders another template within the context of this one.
  
    :param: template    The template to render
    :param: parameters  The parameters to pass to the other template.
  */
  public func renderTemplate(template: Template) {
    self.renderedTemplates.append(template)
    self.buffer.appendString(template.generate())
  }
  

  //MARK: - Controller Information

  /**
    This method gets a single request parameter from the controller.
    */
  public func requestParameter(key: String) -> String? {
    let params = self.controller.request.requestParameters
    return params[key]
  }
  
  /**
    This method gets a subset of the request parameters from the controller

    :param: keys
      The keys to extract

    :returns:
      A hash with the extracted values.
    */
  public func requestParameters(keys: String...) -> [String:String] {
    let params = self.controller.request.requestParameters
    var filteredParams = [String:String]()
    for key in keys {
      filteredParams[key] = params[key]
    }
    return filteredParams
  }
  
  //MARK: - Localization
  
  /** The localization that this template will use by default, if it has one. */
  public var localization: Localization { get { return self.controller.localization } }
  
  /**
    This method gets a localized, capitalized attribute name.

    :param: model           The model whose attribute this is.
    :param: attributeName   The name of the attribute to localize.
    :returns:               The localized attribute.
    */
  public func attributeName(model: Model.Type, _ attributeName: String) -> String {
    return model.humanAttributeName(attributeName, localization: self.localization, capitalize: true)
  }
}