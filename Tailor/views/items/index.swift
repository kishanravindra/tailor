/** The template for the index action in the ItemsController. */
let ItemIndexTemplate = Template {
  (t, parameters) in
  t.tag("html", with: {
    t.tag("body", with: {
      t.tag("h1", attributes: ["style": "color: blue"], with: {
        "test"
      })
    })
  })
}