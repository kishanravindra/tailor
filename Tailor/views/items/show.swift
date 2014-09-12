/** The template for the show action in ItemsController. */
let ItemShowTemplate = Template {
  (t, parameters) in
  t.tag("html", with: {
    t.tag("body", with: {
      t.tag("h1", with: {
        let id = parameters["id"]! as Int
        return "Item \(id)"
      })
    })
  })
}