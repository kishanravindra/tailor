import Tailor
import Foundation

/**
  This struct provides a generic task for generating inventory files.

  This requires the following flags:

  - typeName:   The name of the type we're looking for subtypes of.
  - fileSuffix: The end of the filename for the types that we're including.
  */
final class InventoryGeneratorTask: FileGenerator {
  let typeName: String
  let fileSuffix: String
  var fileContents = ""
  var fileIndentation = 0
  
  var functionName: String {
    return "register\(fileSuffix)s"
  }

  var fileNames: [String] {
    return ["app/\(typeName)Inventory.swift"]
  }

  convenience init() {
    let flags = Application.sharedApplication().flags
    guard let typeName = flags["typeName"] else {
      fatalError("You must provide a type name, e.g. typeName=AlterationScript")
    }
    guard let fileSuffix = flags["fileSuffix"] else {
      fatalError("You must provide a file suffix, e.g. fileSuffix=Alteration")
    }

   self.init(typeName: typeName, fileSuffix: fileSuffix)
  }

  init(typeName: String, fileSuffix: String) {
    self.typeName = typeName
    self.fileSuffix = fileSuffix
  }

  /**
    This method gets the types for this inventory from the files in a directory.

    This will do a recursive search of the directory looking for files that have
    this generator's file suffix.

    - parameter directory:    The directory to search.
    - returns:                The types we found in the filenames in that
                              directory.
    */
  func typesFromDirectory(directory: String) -> [String] {
    var types = [String]()
    do {
      let fileManager = NSFileManager.defaultManager()
      for file in try fileManager.contentsOfDirectoryAtPath(directory) {
        let path = "\(directory)/\(file)"
        var isDirectory = false
        guard fileManager.fileExistsAtPath(path, isDirectory: &isDirectory) else { continue }
        if isDirectory {
          types.appendContentsOf(typesFromDirectory(path))
        }
        else if file.hasSuffix("\(self.fileSuffix).swift") {
          types.append(file.substringToIndex(file.endIndex.advancedBy(-6)))
        }
      }
    }
    catch {}
    return types
  }

  /**
    This method gets the contents for the inventory file.

    - parameter types:    The names of the types that we are putting in the
                          inventory.
    */
  func generateContentsForTypes(types: [String]) -> Void {
    output(
      "import Tailor",
      "extension Application.Configuration {",
      "func \(self.functionName)() {",
      "TypeInventory.shared.registerSubtypes(\(self.typeName).self, subtypes: ["
    )
    for type in types {
      output("\(type).self,")
    }
    output(
      "])",
      "}",
      "}"
    )
  }

  func generateContentsForFile(path: String) -> Void {
    let types = typesFromDirectory("Sources/\(target)")
    self.generateContentsForTypes(types)
  }
}