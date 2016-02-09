import Foundation
import Tailor

/**
  This protocol provides commands for generating inventory files.
  */
protocol TypeInventoryGenerator: FileGenerator {
  /** The name of the type that we are getting subtypes for. */
  static var typeName: String { get }

  /** The suffix for files that contain entries for this inventory. */
  static var fileSuffix: String { get }

  /**
    The name of the function that we will create for registering the subtypes
    in the inventory.

    The default is "register(fileSuffix)s".
    */
  static var functionName: String { get }

  /**
    The built-in types that should always be added to the inventory, even if
    there are no files for them in the source directory.

    The default is an empty list.
    */
  static var builtInTypes: [String] { get }
}

extension TypeInventoryGenerator {
  static var functionName: String {
    return "register\(fileSuffix)s"
  }

  static var builtInTypes: [String] { return [] }

  var fileNames: [String] {
    return ["app/\(self.dynamicType.typeName)Inventory.swift"]
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
        else if file.hasSuffix("\(self.dynamicType.fileSuffix).swift") {
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
      "func \(self.dynamicType.functionName)() {",
      "TypeInventory.shared.registerSubtypes(\(self.dynamicType.typeName).self, subtypes: ["
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
    var types = typesFromDirectory("Sources/\(target)")
    types.appendContentsOf(self.dynamicType.builtInTypes)
    self.generateContentsForTypes(types)
  }
}