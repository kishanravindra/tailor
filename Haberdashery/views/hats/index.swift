/**
  The template for the index action in the HatsController.

  Parameters:

  * hats: A list of hats
  */
let HatIndexTemplate = Template {
  (t, parameters) in
  t.tag("h1", text: "Hats")
  t.tag("div", ["class": "row"]) {
    t.tag("div", ["class": "col-md-6"]) {
      t.link(action: "new", attributes: ["class": "btn btn-primary"], with: {
        t.text("New Hat")
      })
    }
  }
  t.tag("p")
  t.tag("div", ["class": "row"]) {
    t.tag("div", ["class": "col-md-8"]) {
      t.tag("table", ["class": "table"]) {
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
  }
}