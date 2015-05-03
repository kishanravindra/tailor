import Foundation

/**
  This class provides helper methods for building forms.
  */
public class FormBuilder {
  /**
    A block that can build an input for a model property.
  
    :param: form        The form that will hold the input.
    :param: key         The name of the field
    :param: attributes  The HTML attributes to put on the control.
    :param: errors      The errors that we should show in the field.
    */
  public typealias InputBuilder = (form: FormBuilder, key: String, value: String, attributes: [String:String], errors: [ValidationError])->()
  
  /** The template that we are putting the form in. */
  public let template: Template
  
  /** The name of the model. */
  public let name: String
  
  /** The validation errors for the model object. */
  public let validationErrors: [ValidationError]
  
  /** The block that we use to build inputs. */
  public let inputBuilder: InputBuilder
  
  /**
    This method creates a form builder.

    :param: template      The template that we are putting the form in.
    :param: name          The name used for the model object in the input tags.
    :param: inputBuilder  A block we can use to build inputs. If this is not
                          provided, we will use a simple one with a div
                          containing a label and an input.
    */
  public init(template: Template, name: String, validationErrors: [ValidationError] = [], inputBuilder: InputBuilder? = nil) {
    self.template = template
    self.name = name
    self.validationErrors = validationErrors
    
    if inputBuilder == nil {
      self.inputBuilder = {
        (form, key: String, value, attributes, _) -> () in
        form.template.tag("div") {
          var label = key
          if let type = attributes["type"] {
            if type == "radio" {
              label = template.localize("\(name).\(key).\(value)") ?? value
            }
          }
          form.template.tag("label", text: label)
          var mergedAttributes = attributes
          mergedAttributes["name"] = "\(form.name)[\(key)]"
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
  public func form(path: String, _ method: String = "POST", attributes: [String:String] = [:], @noescape with contents: ()->()) {
    var mergedAttributes = attributes
    mergedAttributes["method"] = method
    mergedAttributes["action"] = path
    self.template.tag("form", mergedAttributes, with: contents)
  }
  
  /**
    This method generates an input tag.

    :param: key           The name of the property.
    :param: value         The value to put in the input tag.
    :param: attributes    Additional attributes to set on the input tag.
    */
  public func input(key: String, _ value: String, attributes: [String: String] = [:]) {
    let errors = self.validationErrors.filter { $0.key == key }
    self.inputBuilder(form: self, key: key, value: value, attributes: attributes, errors: errors)
  }
  
  /**
    This method generates a select tag.

    :param: key         The name of the property.
    :param: value       The currently selected value.
    :param: values      A list of pairs that contain the values and labels for
                        the options in the dropdown.
    :param: attributes  Additional attributes to set on the select tag.
    */
  public func dropdown(key: String, value selectedValue: String? = nil, values: [(String, String)], attributes: [String:String] = [:]) {
    var mergedAttributes = attributes
    mergedAttributes["name"] = "\(self.name)[\(key)]"
    self.template.tag("select", mergedAttributes) {
      for (value,label) in values {
        let optionAttributes: [String:String]
        
        if selectedValue != nil && selectedValue! == value {
          optionAttributes = ["selected": "selected", "value": value]
        }
        else {
          optionAttributes = ["value": value]
        }
        self.template.tag("option", text: label, attributes: optionAttributes)
      }
    }
  }
  
  /**
    This method generates a select tag.
    
    :param: key         The name of the property.
    :param: value       The currently selected value.
    :param: values      A list of values for the dropdown. The values will also
                        be the labels for the options.
    :param: attributes  Additional attributes to set on the select tag.
  */
  public func dropdown(key: String, value: String? = nil, values: [String], attributes: [String:String] = [:]) {
    let values = values.map { ($0,$0) }
    self.dropdown(key, value: value, values: values, attributes: attributes)
  }
  
  /**
    This method generates a set of radio button tags.

    Each tag will have the "type" attribute set to radio, and the "value" 
    attribute set to the value that the radio button is for. The default input
    builders will use that value to construct a label, which will be of the form
    (form name).(key).(value).
  
    :param: key           The key for the inputs.
    :param: value         The value that is selected.
    :param: values        The values for the radio buttons.
    :param: attributes    The attributes to set on the input tags.
    */
  public func radioButtons(key: String, value selectedValue: String? = nil, values: [String], attributes: [String:String] = [:]) {
    let mergedAttributes = merge(attributes, ["type": "radio"])
    for value in values {
      let optionAttributes: [String:String]
      
      if selectedValue != nil && selectedValue! == value {
        optionAttributes = merge(mergedAttributes, ["checked": "checked"])
      }
      else {
        optionAttributes = mergedAttributes
      }
      self.input(key, value, attributes: optionAttributes)
    }
  }
}