import Tailor
import Foundation

/**
  This protocol describes a task for generating a set of files.
  */
protocol FileGenerator: TaskType {
  /**
    The paths of the files we are generating, relative to the source root for
    the target.
    */
  var fileNames: [String] { get }

  /**
    This method generates the contents for a file.

    This should use the `output` method to add the lines to the `fileContents`
    buffer.

    - parameter name:   The name of the file.
    */
  func generateContentsForFile(name: String) -> Void

  /**
    This initializer creates a generator.
    */
  init()

  /** The contents of the file we are currently generating. */
  var fileContents: String { get set }

  /** The current indentation level in the file we are generating. */
  var fileIndentation: Int { get set }
}

extension FileGenerator {
  /** The flags from the command line. */
  var flags: [String:String] {
    return Application.sharedApplication().flags
  }

  /**
    This method gets the name of the target that we are putting the files in.

    This will either be the `target` flag, or the first directory within the
    `Sources` directory.
    */
  var target: String {
    if let target = flags["target"] { return target }
    else {
      let directories = (try? NSFileManager.defaultManager().contentsOfDirectoryAtPath("Sources")) ?? []
      return directories.first ?? ""
    }
  }

  /**
    This method outputs new lines to the file.

    - parameter lines:  The lines to add
    */
  func output(lines: String...) {
    for line in lines {
      var fullLine = ""
      if line.hasPrefix("}") || line.hasPrefix("]") {
        fileIndentation -= 1
      }
      for _ in 0..<fileIndentation {
        fullLine += "  "
      }
      fullLine += line + "\n"
      if line.hasSuffix("{") || line.hasSuffix("[") {
        fileIndentation += 1
      }
      fileContents += fullLine
    }
  }

  /**
    This method gets the contents for a file.

    - parameter path:   The file we are getting the contents for.
    - returns:          The contents.
    */
  func contentsForFile(path: String) -> String {
    fileContents = ""
    self.generateContentsForFile(path)
    return fileContents
  }

  /**
    This method generates the files.
    */
  func generateFiles() {
    for name in fileNames {
      let filename = "Sources/\(target)/\(name)"
      print("Generating \(filename)")

      let contents = self.contentsForFile(name)
      let fileData = NSData(bytes: contents.utf8)
      do {
        let directory = filename.stringByDeletingLastPathComponent
        try NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
        try fileData.writeToFile(filename, options: [])
      }
      catch {
        print("Error writing to file")
      }
    }
  }

  static func runTask() {
    self.init().generateFiles()
  }
}