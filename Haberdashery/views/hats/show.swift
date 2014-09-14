/**
  The template for the show action in the HatsController.

  Parameters:

  * hat: The hat to show
*/
let HatShowTemplate = Template {
  (t, parameters) in
  if let hat = parameters["record"] as? Hat {
    t.tag("div") {
      t.tag("label", text: "Color: ")
      t.text(hat.color)
    }
    t.tag("div", ["class": "row"]) {
      t.tag("label") {
        t.text("Brim Size: ")
      }
      if let size = hat.brimSize {
        t.text(size.stringValue)
      }
      else {
        t.text("None")
      }
    }
    
    t.tag("ul") {
      t.tag("li") {
        t.link(action: "index", with: { t.text("Back") })
      }
      t.tag("li") {
        t.link(action: "edit", parameters: ["id": String(hat.id)], with: { t.text("Edit") })
      }
    }
  }
}