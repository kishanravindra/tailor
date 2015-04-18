import Foundation

/**
  This class provides helper methods for building forms.
  */
public class FormBuilder {
  /** A block that can build an input for a model property. */
  public typealias InputBuilder = (form: FormBuilder, key: String, value: String, attributes: [String:String], errors: [ValidationError])->()
  
  /** The template that we are putting the form in. */
  public let template: Template
  
  /** The model that we are representing with the form. */
  public let model: Model
  
  /** The name of the model in the input names. */
  public let name: String
  
  /** The block that we use to build inputs. */
  public let inputBuilder: InputBuilder
  
  /**
    This method creates a form builder.

    :param: template      The template that we are putting the form in.
    :param: model         The model object that the form is for.
    :param: name          The name used for the model object in the input tags.
                          If this is not provided, it will default to the model
                          class's modelName, in lowercase camel case.
    :param: inputBuilder  A block we can use to build inputs. If this is not
                          provided, we will use a simple one with a div
                          containing a label and an input.
    */
  public init(template: Template, model: Model, name: String? = nil, inputBuilder: InputBuilder? = nil) {
    self.template = template
    self.model = model
    self.name = model.dynamicType.modelName().lowercaseInitial
    if inputBuilder == nil {
      self.inputBuilder = {
        (form, key: String, value, attributes, _) -> () in
        form.template.tag("div") {
          form.template.tag("label", text: key)
          var mergedAttributes = attributes
          mergedAttributes["name"] = "\(form.name)[\(form.model.dynamicType.humanAttributeName(key))]"
          mergedAttributes["value"] = value
          form.template.tag("input", mergedAttributes)
        }
      }
    }
    else {
      self.inputBuilder = inputBuilder!
    }
  }
  
  /**
    This method generates a form tag.

    :param: path        The path to submit the form to.
    :param: method      The HTTP method for the form.
    :param: attributes  Additional attributes for the form tag.
    :param: contents    A block that will populate the contents of the form.
    */
  public func form(path: String, _ method: String = "POST", attributes: [String:String] = [:], with contents: ()->()) {
    var mergedAttributes = attributes
    mergedAttributes["method"] = method
    mergedAttributes["action"] = path
    self.template.tag("form", mergedAttributes, with: contents)
  }
  
  /**
    This method generates an input tag.

    :param: key           The name of the property.
    :param: attributes    Additional attributes to set on the input tag.
    */
  public func input(key: String, attributes: [String: String] = [:]) {
    var value : AnyObject? = nil
    var stringValue = ""
    switch(value) {
    case let number as NSNumber:
      stringValue = number.stringValue
    case let integer as Int:
      stringValue = String(integer)
    case let string as String:
      stringValue = string
    default:
      break
    }
    self.inputBuilder(form: self, key: key, value: stringValue, attributes: attributes, errors: self.model.errors[key] ?? [])
  }
}