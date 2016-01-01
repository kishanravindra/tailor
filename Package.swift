import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "../SwiftSqlite", majorVersion: 1)
  ]
)