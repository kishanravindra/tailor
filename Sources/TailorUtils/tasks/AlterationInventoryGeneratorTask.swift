/**
  This type provides a generator for creating an inventory of all the
  alterations defined in the project.
  */
final class AlterationInventoryGeneratorTask: TypeInventoryGenerator {
  static let typeName = "AlterationScript"
  static let fileSuffix = "Alteration"
  static let commandName = "alteration_inventory"
  var fileContents = ""
  var fileIndentation = 0
}