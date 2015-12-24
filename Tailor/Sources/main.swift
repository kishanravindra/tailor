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
let regex = try! NSRegularExpression(pattern: "^([\\S]*) ([\\S]*) HTTP/([\\d.]*)$", options: [])
func checkString(string: String) {
	let match = regex.firstMatchInString(string, options: [], range: NSMakeRange(0,string.characters.count))?.range
	print("\(string): \(match)")
}
print(String(regex.components))
checkString("GET /test/path HTTP/1.1")
checkString("POST /test HTTP/1.1")

ServerTask.runTask()