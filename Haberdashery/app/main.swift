import Foundation

MysqlConnection.open([
  "host": "127.0.0.1",
  "username": "haberdashery",
  "password": "2wsxcde3",
  "database": "haberdashery"
])

HaberdasheryRouteSet.printRoutes()
HaberdasheryApplication.start()

let thing = HatsController<Hat>.self