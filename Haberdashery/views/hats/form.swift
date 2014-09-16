/**
  This template provides a form for adding or updating hat.s

  Parameters:

  * hat: The hat to add or update.
  */
let HatFormTemplate = Template {
  (t, parameters) in
  if let hat = parameters["record"] as? Hat {
    t.tag("h1", text: "Hat")
    var path = ""
    if hat.id == nil {
      path = t.urlFor(action: "create") ?? path
    }
    else {
      path = t.urlFor(action: "update", parameters: ["id": String(hat.id)]) ?? path
    }
    t.tag("div", ["class": "row"]) {
      t.tag("div", ["class": "col-md-6"]) {
        let form = FormBuilder(template: t, model: hat, inputBuilder: t.buildBootstrapInput)
        form.form(path, with: {
          form.input("color")
          form.input("brimSize")
          t.buildFormActions(form)
        })
      }
    }
  }
}
