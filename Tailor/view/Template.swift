import Foundation

/**
  This class provides a template for generating a response to a request.

  This has been deprecated in favor of the TemplateType protocol.
  */
@available(*, deprecated, message="Use TemplateType instead") public class Template: TemplateType {
  /** The internal state of the template. */
  public var state: TemplateState
  
  /** The buffer that we use to build our result. */
  public var buffer: String { return contents }
  
  public var controller: Controller {
    return self.state.controller as! Controller
  }
  
  /**
    This method initializes a template.

    - parameter controller:    The controller that is rendering the template.
    */
  public init(controller: ControllerType) {
    self.state = TemplateState(controller)
  }
  
  //MARK: - Body
  
  /**
    This method runs the body.

    This implementation does nothing. Subclasses must override this to provide
    the real rendered content.

    The content should be added to the buffer instance variable.
    */
  public func body() {
    
  }
  
  //MARK: - Helpers
  
  public var renderedTemplates: [Template] {
    return self.state.renderedTemplates.flatMap { $0 as? Template }
  }
  
  /**
  This method gets the prefix that is appended to the the keys for
  localization.
  This is only added to keys that start with a dot.
  */
  public var localizationPrefix: String {
    return String(reflecting: self.dynamicType).underscored()
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
    let sanitizedText = Sanitizer.htmlSanitizer.sanitize(SanitizedText(stringLiteral: localizedText))
    self.addSanitizedText(sanitizedText)
  }
  
  /**
  This method appends text to our buffer without HTML-sanitizing it.
  Use this with caution, and only when you are certain the text is safe.
  :param: text    The text to add.
  */
  public func raw(text: String, localize: Bool = true) {
    let localizedText = localize ? self.controller.localize(text) ?? text : text
    self.addSanitizedText(Sanitizer.htmlSanitizer.accept(localizedText))
  }
  
  /**
    This method adds sanitized text to our buffer.
    It will check to make sure it is really HTML-sanitized, and sanitize it if
    necessary.
    :param: text    The text to add.
    */
  public func addSanitizedText(text: SanitizedText) {
    let sanitizer = Sanitizer.htmlSanitizer
    if !sanitizer.isSanitized(text) {
      self.addSanitizedText(sanitizer.sanitize(text))
    }
    else {
      self.state.contents.appendContentsOf(text.text)
    }
  }
  
  /**
  This method adds an HTML tag.
  
  :param: name          The name of the element.
  :param: attributes    Additional attributes for the tag.
  :param: with          A closure that adds the contents of the tag.
  */
  public func tag(name: String, _ attributes: [String:String], @noescape with contents: ()->() = {}) -> () {
    var openingTag = "<\(name)"
    
    for key in attributes.keys.sort() {
      let value = attributes[key]!
      openingTag += " \(key)=\"\(value)\""
    }
    openingTag += ">"
    self.state.contents += openingTag
    contents()
    self.state.contents += "</\(name)>"
  }
  
  /**
  This method adds an HTML tag.
  
  This is just a wrapper around the version with explicit attributes, but
  using default values for that parameter causes problems with having a
  trailing closure.
  :param: name          The name of the element.
  :param: contents      A closure that adds the contents of the tag.
  */
  public func tag(name: String, @noescape with contents: ()->() = {}) -> () {
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
  This method adds a tag for linking to a path.
  
  :param: controllerName  The controller to link to. This will default to the
  current controller.
  :param: actionName      The action to link to.
  :param: parameters      Additional parameters for the path.
  :param: attributes      Additional attributes for the tag.
  :param: with            A closure that adds the contents of the link.
  */
  public func link(controllerName controllerName: String? = nil, actionName: String? = nil, parameters: [String:String] = [:], attributes: [String:String] = [:], @noescape with contents: ()->()={}) {
    var mergedAttributes = attributes
    let path = self.controller.pathFor(controllerName: controllerName, actionName: actionName, parameters: parameters)
    mergedAttributes["href"] = path ?? ""
    self.tag("a", mergedAttributes, with: contents)
  }
  
  /**
  This method renders another template within the context of this one.
  
  :param: template    The template to render
  :param: parameters  The parameters to pass to the other template.
  */
  public func renderTemplate(var template: TemplateType) {
    self.state.renderedTemplates.append(template)
    self.state.contents += template.generate()
  }
  
  /**
  This method generates content for the template and stores it in the cache.
  If the content is already in the cache, the cached version will be put into
  the buffer without re-generating it.
  :param: key     The key where the content will be stored in the cache.
  :param: block   The block that will generate the content. This should
  generate the content as you would any other part of the
  template body, using the normal helper methods.
  */
  public func cache(key: String, @noescape block: ()->()) {
    let cache = Application.cache
    if let cachedContent = cache.read(key) {
      self.state.contents += cachedContent
    }
    else {
      let previousLength = self.buffer.characters.count
      block()
      let addedContent = self.buffer.substringFromIndex(self.buffer.startIndex.advancedBy(previousLength))
      cache.write(key, value: addedContent)
    }
  }
  
  
  
  /**
  This method generates the body using the template.
  
  - returns:           The body.
  */
  public func generate() -> String {
    self.state.contents = ""
    self.body()
    return self.state.contents
  }
}