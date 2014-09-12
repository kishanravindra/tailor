import Foundation

MysqlConnection.open([
  "host": "127.0.0.1",
  "username": "haberdashery",
  "password": "2wsxcde3",
  "database": "haberdashery"
])

for record in Hat.find(limit: 1, order: ["color": NSComparisonResult.OrderedDescending]) {
  if let hat = record as? Hat {
    NSLog("Hat has %@ %d", hat.color, hat.brimSize)
  }
}
/*
SHARED_APPLICATION = HaberdasheryApplication()
SHARED_APPLICATION.routeSet.printRoutes()
SHARED_APPLICATION.start()
*/