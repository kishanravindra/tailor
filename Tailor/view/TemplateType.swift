import Foundation

/**
  This structure wraps around the internal state of a template.
  */
public struct TemplateState {
  /** The controller that is rendering the template. */
  public let controller: ControllerType
  
  /** The templates that have been rendered within this one. */
  public var renderedTemplates: [TemplateType] = []
  
  /** The contents that we have rendered. */
  public var contents: String = ""
  
  /**
    This method initializes a template state.

    - parameter controller:   The controller that is rendering the template.
    */
  public init(_ controller: ControllerType) {
    self.controller = controller
  }
}

/**
  This protocol describes a template, which renders a block of HTML.
  */
public protocol TemplateType {
  /**
    The internal state of the template.
  
    We wrap this in a struct to reduce the boilerplate of conforming to the
    protocol.
    */
  var state: TemplateState { get set }
  
  /**
    This method runs the body.
  
    This should make calls to
    */
  mutating func body()
}

extension TemplateType {
  //MARK: - State
  
  /** The controller that the template is rendering. */
  public var controller: ControllerType { return state.controller }
  
  /** The contents that we have rendered. */
  public var contents: String { return state.contents }
  
  //MARK: - Helpers
  
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
    
    - parameter key:    The key to localize.
    - returns:          The localized text.
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
    
    - parameter text:      The text to add.
    - parameter localize:  Whether we should attempt to localize the text.
    */
  public mutating func text(text: String, localize: Bool = true) {
    let localizedText = localize ? self.localize(text) ?? text : text
    let sanitizedText = Sanitizer.htmlSanitizer.sanitize(SanitizedText(stringLiteral: localizedText))
    self.addSanitizedText(sanitizedText)
  }
  
  /**
    This method appends text to our buffer without HTML-sanitizing it.
    
    Use this with caution, and only when you are certain the text is safe.
    
    - parameter text:    The text to add.
    */
  public mutating func raw(text: String, localize: Bool = true) {
    let localizedText = localize ? self.controller.localize(text) ?? text : text
    self.addSanitizedText(Sanitizer.htmlSanitizer.accept(localizedText))
  }
  
  /**
    This method adds sanitized text to our buffer.
    
    It will check to make sure it is really HTML-sanitized, and sanitize it if
    necessary.
    
    - parameter text:    The text to add.
    */
  public mutating func addSanitizedText(text: SanitizedText) {
    let sanitizer = Sanitizer.htmlSanitizer
    if !sanitizer.isSanitized(text) {
      self.addSanitizedText(sanitizer.sanitize(text))
    }
    else {
      self.state.contents += text.text
    }
  }
  
  /**
    This method adds an HTML tag.
    
    - parameter name:          The name of the element.
    - parameter attributes:    Additional attributes for the tag.
    - parameter with:          A closure that adds the contents of the tag.
    */
  public mutating func tag(name: String, _ attributes: [String:String], @noescape with contents: ()->() = {}) -> () {
    var openingTag = "<\(name)"
    
    for key in attributes.keys.sort() {
      if let value = attributes[key] {
        openingTag += " \(key)=\"\(value)\""
      }
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
    
    - parameter name:          The name of the element.
    - parameter contents:      A closure that adds the contents of the tag.
    */
  public mutating func tag(name: String, @noescape with contents: ()->() = {}) -> () {
    self.tag(name, [:], with: contents)
  }
  
  /**
    This method adds an HTML tag.
    
    - parameter name:          The name of the element.
    - parameter attributes:    Additional attributes for the tag.
    - parameter text:          The text for the tag.
    */
  public mutating func tag(name: String, text: String, attributes: [String:String] = [:]) -> () {
    self.tag(name, attributes) { self.text(text) }
  }
  
  /**
    This method adds a tag for linking to a path.
  
    - parameter actionName:       The action to link to.
    - parameter parameters:       Additional parameters for the path.
    - parameter attributes:       Additional attributes for the tag.
    - parameter with:             A closure that adds the contents of the link.
    */
  public mutating func link(actionName actionName: String? = nil, parameters: [String:String] = [:], attributes: [String:String] = [:], @noescape with contents: ()->()={}) {
    self.link(self.controller.dynamicType, actionName: actionName, parameters: parameters, attributes: attributes, with: contents)
  }
  
  /**
    This method adds a tag for linking to a path.
    
    - parameter controllerType:   The controller to link to. This will default to
                                  the current controller.
    - parameter actionName:       The action to link to.
    - parameter parameters:       Additional parameters for the path.
    - parameter attributes:       Additional attributes for the tag.
    - parameter with:             A closure that adds the contents of the link.
    */
  public mutating func link(controllerType: ControllerType.Type, actionName: String? = nil, parameters: [String:String] = [:], attributes: [String:String] = [:], @noescape with contents: ()->()={}) {
    var mergedAttributes = attributes
    mergedAttributes["href"] = self.controller.pathFor(controllerType,
      actionName: actionName, parameters: parameters) ?? ""
    self.tag("a", mergedAttributes, with: contents)
  }
  
  /**
    This method puts a form into the template.
  
    You must provide a name or a type parameter to this method, but you must not
    provide both.
  
    This will add the form tag, build a form object, and give it to the contents
    block so that you can add the inputs to it.
  
    If you call methods on this template in the contents block, the result of
    those methods will not be added in the right place in the template. The form
    maintains its own template for adding content to, and we cannot merge the
    two together. If you want to add any content inside the form other than the
    content added by the form's immediate input methods, you can do that by
    adding the content to the form's template, not this one.
  
    - parameter path:               The path that the form will submit to.
    - parameter method:             The HTTP method that the submission should
                                    use.
    - parameter name:               The name of the model in the form.
    - parameter type:               The type of the model in the form.
    - parameter validationErrors:   The errors that should be shown in the form.
    - parameter attributes:         The attributes to put on the form tag.
    - parameter inputBuilder:       The method to use to build inputs for the
                                    form.
    - parameter contents:           A block that will be run on the form to add
                                    the body of the form.
    */
  public mutating func form(path: String, method: String = "POST", name: String? = nil, type: ModelType.Type? = nil, validationErrors: [ValidationError] = [], attributes: [String:String] = [:], inputBuilder: TemplateForm.InputBuilder? = nil, @noescape with contents: (inout TemplateForm)->()) {
    var mergedAttributes = attributes
    mergedAttributes["method"] = method
    mergedAttributes["action"] = path
    self.tag("form", mergedAttributes) {
      var form = TemplateForm(controller: self.controller, name: name, type: type, validationErrors: validationErrors, inputBuilder: inputBuilder)
      contents(&form)
      self.state.contents += form.template.contents
    }
  }
  
  /**
    This method renders another template within the context of this one.
    
    - parameter template:    The template to render
    - parameter parameters:  The parameters to pass to the other template.
    */
  public mutating func renderTemplate(template: TemplateType) {
    var template = template
    self.state.renderedTemplates.append(template)
    self.state.contents += template.generate()
  }
  
  /**
    This method generates content for the template and stores it in the cache.
    
    If the content is already in the cache, the cached version will be put into
    the buffer without re-generating it.
    
    - parameter key:      The key where the content will be stored in the cache.
    - parameter block:    The block that will generate the content. This should
                          generate the content as you would any other part of
                          the template body, using the normal helper methods.
    */
  public mutating func cache(key: String, @noescape block: ()->()) {
    if let cachedContent = Application.cache.read(key) {
      self.state.contents += cachedContent
    }
    else {
      let previousEnd = contents.characters.endIndex
      block()
      let range = Range(start: previousEnd, end: contents.characters.endIndex)
      let addedContent = contents[range]
      Application.cache.write(key, value: addedContent, expireIn: nil)
    }
  }
  
  
  /**
    This method generates the body using the template.
    
    - returns:           The body.
    */
  public mutating func generate() -> String {
    self.state.contents = ""
    self.body()
    return self.state.contents
  }
  
  //MARK: - Controller Information
  
  /**
    This method gets a single request parameter from the controller.
    */
  public func requestParameter(key: String) -> String? {
    return self.controller.request.params[key]
  }
  
  /**
    This method gets a subset of the request parameters from the controller
    
    - parameter keys:   The keys to extract
    - returns:          A hash with the extracted values.
    */
  public func requestParameters(keys: String...) -> [String:String] {
    let params = self.controller.request.params.raw
    var filteredParams = [String:String]()
    for key in keys {
      filteredParams[key] = params[key]
    }
    return filteredParams
  }
  
  //MARK: - Localization
  
  /** The localization that this template will use by default, if it has one. */
  public var localization: LocalizationSource { get { return self.controller.localization } }
  
  /**
    This method gets a localized, capitalized attribute name.

    - parameter modelName:        The name of the model whose attribute this is.
    - parameter attributeName:    The name of the attribute to localize.
    - returns:                    The localized attribute.
    */
  public func attributeName(modelType: ModelType.Type, _ attributeName: String) -> String {
    return modelType.attributeName(attributeName, localization: self.localization, capitalize: true)
  }
}