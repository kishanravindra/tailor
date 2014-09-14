/** This template provides a layout for our application. */
let HaberdasheryLayout = Template {
  (t, parameters) in
  
  t.tag("html") {
    t.tag("body") {
      t.body(t, parameters)
    }
  }
}