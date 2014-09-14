/**
  The template for the show action in the HatsController.

  Parameters:

  * hat: The hat to show
*/
let HatShowTemplate = Template {
  (t, parameters) in
  if let hat = parameters["record"] as? Hat {
    t.tag("h1", text: "Hat")
    t.tag("div", ["class": "row"]) {
      t.tag("div", ["class": "col-md-4"]) {
        t.tag("table", ["class": "table"]) {
          t.tag("tr") {
            t.tag("th", text: "Color: ")
            t.tag("td", text: hat.color ?? "None")
          }
          t.tag("tr") {
            t.tag("th", text: "Brim Size: ")
            t.tag("td", text: hat.brimSize?.stringValue ?? "None")
          }
          t.tag("tr") {
            t.tag("th", text: "Created At")
            
            t.tag("td", text: hat.createdAt?.format("long") ?? "N/A")
          }
          t.tag("tr") {
            t.tag("th", text: "Updated At")
            t.tag("td", text: hat.updatedAt?.format("long") ?? "N/A")
          }
        }
      }
    }
    
    t.tag("div", ["class": "row"]) {
      t.tag("div", ["class": "col-md-1"]) {
        t.link(action: "edit", attributes: ["class": "btn btn-primary"], parameters: ["id": String(hat.id)], with: { t.text("Edit") })
      }
      t.tag("div", ["class": "col-md-1"]) {
        t.link(action: "index", attributes: ["class": "btn"], with: { t.text("Back") })
      }
    }
  }
}