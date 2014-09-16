import Foundation

/**
  This extension provides helper methods for our bootstrap forms.
  */
extension Template {
  /**
    This method builds an input using Bootstrap styles.

    :param: form        The form that we are putting the input in.
    :param: key         The name of the property the input is for.
    :param: value       The current value for the property.
    :param: attributes  The attributes to add to the input.
    :param: errors      The validation errors on the model for this field.
    */
  func buildBootstrapInput(form: FormBuilder, key: String, value: String, attributes: [String:String], errors: [String]) {
    
    let t = form.template
    var inputClass = "form-group"
    if !errors.isEmpty {
      inputClass += " has-error"
    }
    t.tag("div", ["class": inputClass]) {
      var mergedAttributes = attributes
      mergedAttributes["class"] = "form-control"
      mergedAttributes["name"] = "\(form.name)[\(key)]"
      mergedAttributes["value"] = value
      t.tag("label", text: form.model.dynamicType.humanAttributeName(key), attributes: ["class": "control-label"])
      t.tag("input", mergedAttributes)
      for error in errors {
        t.tag("p", text: error, attributes: ["class": "help-block"])
      }
    }
  }

  /**
    This method builds a footer with form actions for a record.

    It will have links to save the record and go back to the list of records.

    :param: form    The form that we are putting the actions in.
    */
  func buildFormActions(form: FormBuilder) {
    let t = form.template
    var id : Int? = nil
    if let record = form.model as? Record {
      id = record.id
    }
    t.tag("div", ["class": "row"]) {
      t.tag("div", ["class": "col-md-2"]) {
        t.tag("input", ["class": "btn btn-success", "type": "submit", "value": "Save"])
      }
      
      t.tag("div", ["class": "col-md-2"]) {
        if id == nil {
          t.link(action: "index", attributes: ["class": "btn"], with: {
            t.text("Back")
          })
        }
        else {
          t.link(action: "show", parameters: ["id": String(id!)], attributes: ["class": "btn"], with: {
            t.text("Back")
          })
        }
      }
    }
  }
}