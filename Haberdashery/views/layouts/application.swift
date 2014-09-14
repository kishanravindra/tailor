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
          t.tag("a", attributes: ["class": "navbar-brand"], text: "Haberdashery")
        }
      }
      t.tag("div", ["class": "container"]) {
        t.body(t, parameters)
      }
      t.tag("script", ["type": "text/javascript", "src": "//code.jquery.com/jquery-1.11.0.min.js"])
      t.tag("script", ["type": "text/javascript", "src": "//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"])
    }
  }
}