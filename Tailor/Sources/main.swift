import Foundation
RouteSet.load {
	routes in
	routes.addRoute(.Get("items")) {
		request, responseCallback in
		var response = Response()
		response.appendString("Hello, world")
		responseCallback(response)
	}
	routes.addRoute(.Get("items/:id")) {
		request, responseCallback in
		var response = Response()
		let id = request.params["id"] as Int
		response.appendString("Item \(id)")
		responseCallback(response)
	}
}
let regex = try! NSRegularExpression(pattern: "\\S+", options: [])
print(String(regex.components))
print(String(regex.firstMatchInString("abc", options: [], range: NSMakeRange(0,3))?.range))
print(String(regex.firstMatchInString("  ", options: [], range: NSMakeRange(0,2))))
ServerTask.runTask()