/**
  This type provides a generator for creating an inventory of all the
  alterations defined in the project.
  */
struct AlterationInventoryGenerator: TypeInventoryGenerator {
  static let typeName = "AlterationScript"
  static let fileSuffix = "Alteration"
}