import Tailor

/**
  This class provides a task for generating a model.

  This takes the following flags:

  - name:     The name of the model. This is required.
  - fields:   The fields to add to the model. This should be in the format
              `color:String,size:Int` to add a color field that is a string and
              a size field that is an Int.
  */
final class ModelGeneratorTask: FileGenerator {
  static let commandName = "model"
  var fileContents = ""
  var fileIndentation = 0
  
  init() {
    if name == "" {
      fatalError("You must provide a name for the model (e.g. name=Hat)")
    }
    if fields == [] {
      fatalError("You must provide the fields for the model (e.g. fields=color:String,size:Int)")
    }
  }

  /** The name of the model. */
  var name: String {
    return flags["name"] ?? ""
  }

  /**
    The fields for the model.

    Each entry will be in the format "name:Type".
    */
  var fields: [String] {
    return (flags["fields"] ?? "").componentsSeparatedByString(",")
  }

  var fileNames: [String] {
    return [
      "models/\(name).swift",
      "../\(target)Tests/models/Test\(name).swift",
    ]
  }

  func generateModelContents() {
    var parsedFields = [(String,String)]()
    for field in fields {
      let components = field.componentsSeparatedByString(":")
      if components.count < 2 {
        fatalError("Cannot parse field \(field)")
      }
      parsedFields.append((components[0], components[1]))
    }

    output(
      "import Tailor",
      "",
      "struct \(name): Persistable, Equatable {",
      "let id: UInt"
    )
    for (key,type) in parsedFields {
      output("let \(key): \(type)")
    }
    output("")

    let initializerTypes = parsedFields.map { "\($0): \($1)"}.joinWithSeparator(", ")
    output(
      "init(\(initializerTypes)) {",
      "self.id = 0"
    )
    for (key,_) in parsedFields {
      output("self.\(key) = \(key)")
    }
    output(
      "}",
      ""
    )

    output(
      "init(deserialize values: SerializableValue) throws {",
      "id = try values.read(\"id\")"
    )
    for (key,_) in parsedFields {
      let column = key.underscored()
      output("\(key) = try values.read(\"\(column)\")")
    }
    output(
      "}",
      ""
    )

    output(
      "func valuesToPersist() -> [String: SerializationEncodable?] {",
      "return ["
    )
    for (key,_) in parsedFields {
      let column = key.underscored()
      output("\"\(column)\": \(key),")
    }
    output(
      "]",
      "}",
      ""
    )

    output("static let query = Query<\(name)>()", "")

    output(
      "}"
    )
  }

  func generateTestContents() -> Void {
    output(
      "@testable import \(target)",
      "import TailorTesting",
      "struct Test\(name): TailorTestable {",
      "",
      "var allTests: [(String, () throws -> Void)] { return [",
      "] }",
      "func setUp() {",
      "setUpTestCase()",
      "}",
      "}"
    )
  }

  func generateContentsForFile(path: String) -> Void {
    switch(path) {
      case fileNames[0]: self.generateModelContents()
      case fileNames[1]: self.generateTestContents()
      default: return
    }
  }

  static func runTask() {
    self.init().generateFiles()
  }
}