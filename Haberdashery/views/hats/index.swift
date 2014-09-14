/**
  The template for the index action in the HatsController.

  Parameters:

  * hats: A list of hats
  */
let HatIndexTemplate = Template {
  (t, parameters) in
  t.link(action: "new", with: {
    t.text("New Hat")
  })
  t.tag("table") {
    t.tag("tr") {
      t.tag("th", text: "Color")
      t.tag("th", text: "Brim Size")
      t.tag("th", text: "Actions")
    }
    if let hats = parameters["records"] as? [Hat] {
      for hat in hats {
        t.tag("tr") {
          t.tag("td", text: hat.color)
          t.tag("td", text: hat.brimSize?.stringValue ?? "")
          t.tag("td") {
            t.link(action: "show", parameters: ["id": String(hat.id)], with: {
              t.text("Show")
            })
          }
        }
      }
    }
  }
}