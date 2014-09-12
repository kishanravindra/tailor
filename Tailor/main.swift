import Foundation

MysqlConnection.open([
  "host": "127.0.0.1",
  "username": "haberdashery",
  "password": "2wsxcde3",
  "database": "haberdashery"
])

let results = DatabaseConnection.sharedConnection().executeQuery("SELECT * FROM hats WHERE color = ?", "black")
for result in results {
  let id = result.data["id"]! as Int
  if let value = result.data["created_at"] as? NSDate {
    NSLog("%d %@", id, value)
  }
}
/*
SHARED_APPLICATION = HaberdasheryApplication()
SHARED_APPLICATION.routeSet.printRoutes()
SHARED_APPLICATION.start()
*/