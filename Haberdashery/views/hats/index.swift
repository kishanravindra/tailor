/**
  The template for the index action in the HatsController.

  Parameters:
  - hats: A list of hats
  */
let HatIndexTemplate = Template {
  (t, parameters) in
  t.tag("html", with: {
    t.tag("body", with: {
      t.tag("table", with: {
        t.tag("tr", with: {
          t.tag("th", with: { t.text("Color") })
          t.tag("th", with: { t.text("Brim Size") })
        })
        if let hats = parameters["hats"] as? [Hat] {
          for hat in hats {
            t.tag("tr", with: {
              t.tag("td", with: { t.text(hat.color) })
              t.tag("td", with: { t.text(hat.brimSize?.stringValue ?? "") })
            })
          }
        }
      })
    })
  })
}
