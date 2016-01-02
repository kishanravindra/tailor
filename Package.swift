import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/brownleej/swift-sqlite", majorVersion: 1)
  ]
)