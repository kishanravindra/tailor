import Tailor
import XCTest
import Foundation

/**
  This protocol describes a test for a template.
  */
public protocol TemplateTestable: class, TailorTestable {
  /** The type of controller for the template that we are testing. */
  associatedtype TestedControllerType: ControllerType
  
  /** The type of template that we are testing. */
  associatedtype TestedTemplateType: TemplateType
  
  /** The controller that we are testing. */
  var controller: TestedControllerType { get set }
  
  /** The template that we are testing. */
  var template: TestedTemplateType { get }
}

extension TemplateTestable {
  //MARK: - Template Information
  
  /**
    The state of the template after rendering.
    
    Note: This will re-render the template on every call, so if you are going
    to test the template multiple times in one call, you should cache the
    result.
    */
  public var renderedState: TemplateState {
    var template = self.template
    template.generate()
    return template.state
  }
  
  /**
    The contents of the template after rendering.
    
    Note: This will re-render the template on every call, so if you are going
    to test the template multiple times in one call, you should cache the
    result.
    */
  public var contents: String { return renderedState.contents }
  
  
  /**
    This method builds the controller for the template.
    
    - parameter type:         The type of controller that will be rendering the
                              template.
    - parameter actionName:   The name of the  action on the controller that is
                              being called.
    - parameter user:         The user who is signed in to the controller.
    - parameter parameters:   The request parameters
    */
  public func setUpController(actionName: String = "index", user: UserType! = nil, parameters: [String:String] = [:]) {
    
    var request = Request(parameters: parameters)
    if user != nil {
      request = Request(sessionData: ["userId": String(user.id ?? 0)], parameters: parameters)
    }
    do {
      controller = try TestedControllerType.init(state: ControllerState(request: request, response: Response(), actionName: actionName, callback: {_ in}))
    }
    catch let error {
      NSLog("Error creating test controller: %@", String(error))
    }
  }
}

extension TemplateTestable {
  /**
    This method asserts that an XML document contains an element.

    - parameter xml:            The XML text.
    - parameter elementName:    The name of the element we are checking for.
    - parameter attributes:     Extra attributes that the element needs to have.
    - parameter message:        The message to show if the test fails.
    - parameter file:           The file that the assertion came from. You
                                should generally omit this.
    - parameter line:           The line that the assertion came from. You
                                should generally omit this.
    - parameter contents:       A block to run additional checks on the element.
    */
  public func assert(xml: String, containsElement elementName: String, attributes: [String:String] = [:], message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__, @noescape contents: (NSXMLElement)->Void = {_ in}) {
    assert(xml, containsElement: true, elementName: elementName, attributes: attributes, message: message, file: file, line: line, contents: contents)
  }
  
  
  /**
    This method asserts that an XML document does not contain an element.
    
    - parameter xml:            The XML text.
    - parameter elementName:    The name of the element we are checking for.
    - parameter attributes:     Extra attributes that the element needs to have.
    - parameter message:        The message to show if the test fails.
    - parameter file:           The file that the assertion came from. You
                                should generally omit this.
    - parameter line:           The line that the assertion came from. You
                                should generally omit this.
    */
  public func assert(xml: String, doesNotContainElement elementName: String, attributes: [String:String] = [:], message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    assert(xml, containsElement: false, elementName: elementName, attributes: attributes, message: message, file: file, line: line) { _ in }
  }
  
  /**
    This method asserts that an XML document contains an element.
    
    - parameter xml:            The XML document.
    - parameter elementName:    The name of the element we are checking for.
    - parameter attributes:     Extra attributes that the element needs to have.
    - parameter message:        The message to show if the test fails.
    - parameter file:           The file that the assertion came from. You
                                should generally omit this.
    - parameter line:           The line that the assertion came from. You
                                should generally omit this.
    - parameter contents:       A block to run additional checks on the element.
    */
  public func assert(xml: NSXMLElement, containsElement elementName: String, attributes: [String:String] = [:], message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__, @noescape contents: (NSXMLElement)->Void = {_ in}) {
    assert(xml, containsElement: true, elementName: elementName, attributes: attributes, message: message, file: file, line: line, contents: contents)
  }
  
  /**
    This method asserts that an XML document does not contain an element.
    
    - parameter xml:            The XML document.
    - parameter elementName:    The name of the element we are checking for.
    - parameter attributes:     Extra attributes that the element needs to have.
    - parameter message:        The message to show if the test fails.
    - parameter file:           The file that the assertion came from. You
                                should generally omit this.
    - parameter line:           The line that the assertion came from. You
                                should generally omit this.
  */
  public func assert(xml: NSXMLElement, doesNotContainElement elementName: String, attributes: [String:String] = [:], message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    assert(xml, containsElement: false, elementName: elementName, attributes: attributes, message: message, file: file, line: line) { _ in }
  }
  
  /**
    This method asserts that an XML document either does or does not contain an
    element.
    
    - parameter xml:              The XML text.
    - parameter containsElement:  Whether the document should contains the
                                  element.
    - parameter elementName:      The name of the element we are checking for.
    - parameter attributes:       Extra attributes that the element needs to have.
    - parameter message:          The message to show if the test fails.
    - parameter file:             The file that the assertion came from. You
                                  should generally omit this.
    - parameter line:             The line that the assertion came from. You
                                  should generally omit this.
    - parameter contents:         A block to run additional checks on the element.
    */
  private func assert(xml: String, containsElement: Bool, elementName: String, attributes: [String:String], message: String, file: StaticString, line: UInt, @noescape contents: (NSXMLElement)->Void) {
    do {
      let body = try NSXMLDocument(XMLString: "<html><body>\(xml)</body></html>", options: 0)
      if let element = body.rootElement() {
        assert(element, containsElement: containsElement, elementName: elementName, attributes: attributes, message: message, file: file, line: line, contents: contents)
      }
      else {
        var fullMessage = "Document \(xml) had no root element"
        if !message.isEmpty { fullMessage = "\(message) - " + fullMessage }
        XCTFail(fullMessage, file: file, line: line)
      }
    }
    catch {
      var fullMessage = "Document \(xml) was not a valid XML document"
      if !message.isEmpty { fullMessage = "\(message) - " + fullMessage }
      XCTFail(fullMessage, file: file, line: line)
    }
  }
  
  /**
    This method asserts that an XML document either does or does not contain an
    element.
    
    - parameter xml:              The XML document.
    - parameter containsElement:  Whether the document should contains the
                                  element.
    - parameter elementName:      The name of the element we are checking for.
    - parameter attributes:       Extra attributes that the element needs to have.
    - parameter message:          The message to show if the test fails.
    - parameter file:             The file that the assertion came from. You
                                  should generally omit this.
    - parameter line:             The line that the assertion came from. You
                                  should generally omit this.
    - parameter contents:         A block to run additional checks on the element.
    */
  private func assert(xml: NSXMLElement, containsElement: Bool, elementName: String, attributes: [String:String], message: String, file: StaticString, line: UInt, @noescape contents: (NSXMLElement)->Void) {
    if let child = xml.findElement(elementName, attributes: attributes) {
      if containsElement {
        contents(child)
      }
      else {
        var fullMessage = "\(xml) contained element \(child) matching \(elementName)(\(attributes))"
        if !message.isEmpty { fullMessage = "\(message) - \(fullMessage)" }
        XCTFail(fullMessage, file: file, line: line)
      }
    }
    else if containsElement {
      var fullMessage = "\(xml) did not contain an element matching \(elementName)(\(attributes))"
      if !message.isEmpty { fullMessage = "\(message) - \(fullMessage)" }
      XCTFail(fullMessage, file: file, line: line)
    }
  }
}

extension NSXMLElement {
  /**
    This method fetches an element from this XML tree.

    - parameter elementName:    The name of the element.
    - parameter attributes:     The attributes that the element should have.
    - returns:                  The matching element.
    */
  public func findElement(elementName: String, attributes: [String:String]) -> NSXMLElement? {
    if self.name == elementName {
      var isMatch = true
      for (key,value) in attributes {
        if self.attributeForName(key)?.stringValue != value {
          isMatch = false
          break
        }
      }
      if isMatch {
        return self
      }
    }
    for child in self.children ?? [] {
      if let childElement = child as? NSXMLElement,
        let element = childElement.findElement(elementName, attributes: attributes) {
          return element
      }
    }
    return nil
  }
}