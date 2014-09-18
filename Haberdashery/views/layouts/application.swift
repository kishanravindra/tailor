/** This template provides a layout for our application. */
let HaberdasheryLayout = Template {
  (t, parameters) in
  
  t.tag("html") {
    t.tag("body") {
      t.tag("link", ["rel": "stylesheet", "href": "//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css"])
      t.tag("link", ["rel": "stylesheet", "href": "//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css"])
      t.tag("link", ["rel": "stylesheet", "href": "/assets/application.css"])
      
      t.tag("div", ["class": "navbar navbar-inverse navbar-fixed-top"]) {
        t.tag("div", ["class": "navbar-header"]) {
          t.tag("a", text: "Haberdashery", attributes: ["class": "navbar-brand"])
        }
      }
      t.tag("div", ["class": "container"]) {
        for key in ["success", "error"] {
          if let message = t.controller?.session.flash(key) {
            t.tag("div", ["class": "alert alert-\(key)"]) {
              t.tag("button", ["type": "button", "class": "close", "data-dismiss": "alert"]) { t.text("&times;") }
              t.tag("div", text: message)
            }
          }
        }
        t.body(t, parameters)
      }
      t.tag("script", ["type": "text/javascript", "src": "//code.jquery.com/jquery-1.11.0.min.js"])
      t.tag("script", ["type": "text/javascript", "src": "//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"])
    }
  }
}