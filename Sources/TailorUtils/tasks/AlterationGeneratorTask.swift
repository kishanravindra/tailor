import Tailor

/**
  This class provides a task for generating an alteration.

  This takes the following flags:

  - name:   The name of the alteration. This is required.
  */
final class AlterationGeneratorTask: FileGenerator {
  static let commandName = "alteration"
  var fileContents = ""
  var fileIndentation = 0
  
  init() {
    if name == "" {
      fatalError("You must provide a name for the alteration (e.g. name=CreateMyTable)")
    }
  }

  /** The name of the alteration. */
  var name: String {
    return flags["name"] ?? ""
  }

  var fileNames: [String] {
    return ["alterations/\(name)Alteration.swift"]
  }

  func generateContentsForFile(path: String) -> Void {
    let timestamp = Timestamp.now().format(TimeFormat(.Year,.Month,.Day,.Hour,.Minute,.Seconds))
    output(
      "import Tailor",
      "final class \(name)Alteration: AlterationScript {",
      "static let identifier = \"\(timestamp)\"",
      "static func run() {",
      "query(",
      ")",
      "}",
      "}"
    )
  }

  static func runTask() {
    self.init().generateFiles()
    AlterationInventoryGeneratorTask.runTask()
  }
}