/**
  This template provides a form for adding or updating hat.s

  Parameters:

  * hat: The hat to add or update.
  */
let HatFormTemplate = Template {
  (t, parameters) in
  if let hat = parameters["record"] as? Hat {
    var path = ""
    if hat.id == nil {
      path = t.urlFor(action: "create") ?? path
    }
    else {
      path = t.urlFor(action: "update", parameters: ["id": String(hat.id)]) ?? path
    }
    t.tag("form", ["method": "POST", "action": path]) {
      t.tag("div") {
        t.tag("label", text: "Color")
        t.tag("input", ["name": "hat[color]", "value": hat.color ?? ""])
      }
      t.tag("div") {
        t.tag("label", text: "Brim Size")
        t.tag("input", ["name": "hat[brimSize]", "value": hat.brimSize?.stringValue ?? ""])
      }
      t.tag("input", ["type": "submit", "value": "Save"])
    }
  }
}