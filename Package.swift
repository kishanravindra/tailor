import PackageDescription

let package = Package(
  dependencies: [
    .Package(url: "https://github.com/brownleej/swift-sqlite", majorVersion: 1),
    .Package(url: "https://github.com/brownleej/swift-openssl", majorVersion: 1)
  ],
  targets: [
  	Target(name: "Tailor"),
  	Target(name: "TailorSqlite", dependencies: [
  		.Target(name: "Tailor")
  	]),
    Target(name: "TailorUtils", dependencies: [
      .Target(name: "Tailor")
    ]),
  	Target(name: "ScratchProject", dependencies: [
  		.Target(name: "Tailor"),
  		.Target(name: "TailorSqlite")
  	]),
  	Target(name: "TailorTesting", dependencies: [
  		.Target(name: "Tailor")
  	]),
  	Target(name: "TailorTests", dependencies: [
  		.Target(name: "Tailor"),
  		.Target(name: "TailorSqlite"),
  		.Target(name: "TailorTesting")
  	]),
  ]
)