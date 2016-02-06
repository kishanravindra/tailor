import Foundation
import Tailor

/**
  This protocol provides commands for generating inventory files.
  */
protocol TypeInventoryGenerator {
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

  /**
    This method gets the types for this inventory from the files in a directory.

    This will do a recursive search of the directory looking for files that have
    this generator's file suffix.

    - parameter directory:    The directory to search.
    - returns:                The types we found in the filenames in that
                              directory.
    */
  static func typesFromDirectory(directory: String) -> [String] {
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
        else if file.hasSuffix("\(fileSuffix).swift") {
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
    - returns:            The file contents.
    */
  static func fileContents(types: [String]) -> String {
    var contents = "import Tailor\nfunc \(functionName)() {\n"
    contents += "  TypeInventory.shared.registerSubtypes(\(typeName).self, subtypes: [\n"
    contents += types.map { "    \($0).self" }.joinWithSeparator(",\n")
    contents += "\n  ])\n}"
    return contents
  }

  /**
    This method generates our inventory file.
    */
  static func run() throws {
    let target: String
    if Process.arguments.count > 3 {
      target = Process.arguments[3]
    }
    else {
      let directories = try NSFileManager.defaultManager().contentsOfDirectoryAtPath("Sources")
      target = directories.first ?? ""
    }
    var types = typesFromDirectory("Sources/\(target)")
    types.appendContentsOf(self.builtInTypes)
    let contents = fileContents(types)
    let fileData = NSData(bytes: contents.utf8)
    let filename = "Sources/\(target)/\(typeName)Inventory.swift"
    try fileData.writeToFile(filename, options: [])
    print("Inventory saved to \(filename)")
  }
}