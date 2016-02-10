import Tailor

/**
  This class provides a generator for creating a template.
  */
final class TemplateGeneratorTask: FileGenerator {
  static let commandName = "template"

  /** The name of the template. */
  let name: String

  /** The name of the controller. */
  let controller: String

  /** The contents of the current file. */
  var fileContents = ""

  /** The indentation of the current file. */
  var fileIndentation = 0

  convenience init() {
    let flags = Application.sharedApplication().flags
    guard let name = flags["name"] else {
      fatalError("You must provide a name, e.g. name=Index")
    }
    guard let controller = flags["controller"] else {
      fatalError("You must provide a controller, e.g. controller=Hat")
    } 

    self.init(name: name.camelCase(capitalize: true), controller: controller.camelCase(capitalize: true))
  }

  init(name: String, controller: String) {
    self.name = name
    self.controller = controller
  }

  var fileNames: [String] {
    return [
      "views/\(controller)\(name)Template.swift",
      "../\(target)Tests/views/Test\(controller)\(name)Template.swift"
    ]
  }

  /** This method generates the file for the controller. */
  func generateTemplateFile() {
    output(
      "import Tailor",
      "",
      "extension \(controller)Controller {",
      "struct \(name)Template: TemplateType {",
      "var state: TemplateState",
      "",
      "init(controller: \(controller)Controller) {",
      "state = TemplateState(controller)",
      "}",
      "",
      "mutating func body() {",
      "}",
      "}",
      "}"
    )
  }

  /** This method generates the contents of the file for testing the controller. */
  func generateTestFile() {
    output(
      "@testable import \(target)",
      "import TailorTesting",
      "import Tailor",
      "",
      "final class Test\(controller)\(name)Template: TemplateTestable {",
      "var controller = \(controller)Controller(state: ControllerState())",
      "var template: \(controller)Controller.\(name)Template {",
      "return .init(controller: controller)",
      "}",
      "",
      "var allTests: [(String, () throws -> Void)] { return [",
      "] }",
      "}"
    )
  }

  func generateContentsForFile(path: String) {
    switch(path) {
      case self.fileNames[0]: generateTemplateFile()
      case self.fileNames[1]: generateTestFile()
      default: return
    }
  }
}