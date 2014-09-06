import Foundation

Server().start((127,0,0,1), port: 8080, handler: {
  (request, callback) -> () in
  var response = Response()
  NSLog("Request headers are %@", request.headers)
  NSLog("Request data is %@", request.requestParameters)
  response.appendString("Hello, world")
  callback(response)
})