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
        t.tag("form", ["method": "POST", "action": path]) {
          t.tag("div", ["class": "form-group"]) {
            t.tag("label", text: "Color")
            t.tag("input", ["class": "form-control", "name": "hat[color]", "value": hat.color ?? ""])
          }
          t.tag("div", ["class": "form-group"]) {
            t.tag("label", text: "Brim Size")
            t.tag("input", ["class": "form-control", "name": "hat[brimSize]", "value": hat.brimSize?.stringValue ?? ""])
          }
          t.tag("div", ["class": "row"]) {
            t.tag("div", ["class": "col-md-2"]) {
              t.tag("input", ["class": "btn btn-success", "type": "submit", "value": "Save"])
            }
            t.tag("div", ["class": "col-md-2"]) {
              if hat.id == nil {
                t.link(action: "index", attributes: ["class": "btn"], with: {
                  t.text("Back")
                })
              }
              else {
                t.link(action: "show", parameters: ["id": String(hat.id)], attributes: ["class": "btn"], with: {
                  t.text("Back")
                })
              }
            }
          }
        }
      }
    }
  }
}
