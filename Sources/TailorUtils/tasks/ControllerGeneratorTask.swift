import Tailor

/**
  This class provides a generator for creating a controller.
  */
final class ControllerGeneratorTask: FileGenerator {
  static let commandName = "controller"
  let name: String
  let actions: [String]

  /** The contents of the current file. */
  var fileContents = ""

  /** The indentation of the current file. */
  var fileIndentation = 0

  convenience init() {
    let flags = Application.sharedApplication().flags
    guard let name = flags["name"] else {
      fatalError("You must provide a name, e.g. name=HatsController")
    }
    let actions: [String]

    if let flagString = flags["actions"] {
      actions = flagString.componentsSeparatedByString(",")
    }
    else {
      actions = []
    } 

    self.init(name: name, actions: actions)
  }

  init(name: String, actions: [String]) {
    self.name = name
    self.actions = actions
  }

  var fileNames: [String] {
    return [
      "controllers/\(name)Controller.swift",
      "../\(target)Tests/controllers/Test\(name)Controller.swift"
    ]
  }

  /** This method generates the file for the controller. */
  func generateControllerFile() {
    output(
      "import Tailor",
      "",
      "struct \(name)Controller: ControllerType {",
      "let state: ControllerState",
      ""
    )

    output(
      "static func defineRoutes(routes: RouteSet) {"
    )
    for action in actions {
      output("routes.route(.Get(\"\(action)\"), to: \(action), name: \"\(action)\")")
    }
    output(
      "}",
      ""
    )

    output(
      "init(state: ControllerState) {",
      "self.state = state",
      "}",
      ""
    )

    for action in actions {
      output(
        "func \(action)() {",
        "}",
        ""
      )
    }

    output("}")
  }

  /** This method generates the contents of the file for testing the controller. */
  func generateTestFile() {
    output(
      "@testable import \(target)",
      "import TailorTesting",
      "",
      "final class Test\(name)Controller: ControllerTestable {",
      "typealias TestedControllerType=\(name)Controller",
      "var params = [String: [String:String]]()",
      "",
      "var allTests: [(String, () throws -> Void)] { return [",
      "] }",
      "}"
    )
  }

  func generateContentsForFile(path: String) {
    switch(path) {
      case self.fileNames[0]: generateControllerFile()
      case self.fileNames[1]: generateTestFile()
      default: return
    }
  }
}