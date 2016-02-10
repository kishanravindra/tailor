import Tailor

/**
  This class provides a task for generating an alteration.
  */
final class AlterationGeneratorTask: FileGenerator {
  static let commandName = "alteration"

  /** The name of the alteration. */
  let name: String

  var fileContents = ""
  var fileIndentation = 0
  
  /**
    This initializer creates the task from the flags.

    ### Flags:

    - name:   The name of the alteration. This is required.
    */
  convenience init() {
    let flags = Application.sharedApplication().flags
    guard let name = flags["name"] else {
      fatalError("You must provide a name for the alteration (e.g. name=CreateMyTable)")
    }
    self.init(name: name)
  }

  /**
    This initializer creates an alteration by name.
    */
  init(name: String) {
    self.name = name
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

  func generate() {
    generateFiles()
    AlterationInventoryGeneratorTask.runTask()
  }
}