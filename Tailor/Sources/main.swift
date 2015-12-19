Connection.startServer((0,0,0,0), port: 8080) {
	request, responseCallback in
	var response = Response()
	response.appendString("Hello, world")
	responseCallback(response)
}