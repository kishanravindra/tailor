/**
  This type provides a command for generating files.

  This can be called as `generate [type]`, where type is the type of file to
  generate. The available types are:

  - alteration_inventory
  - task_inventory
  */
struct Generator {
  /** The short explanation of how to invoke this command. */
  static let usage = "- TailorUtils generate [alteration_inventory|task_inventory]"

  /**
    This method runs the generator.
    */
  static func run() throws {
    if Process.arguments.count < 3 {
      throw UsageError.IncorrectUsage(usage)
    }
    switch(Process.arguments[2]) {
    case "alteration_inventory": try AlterationInventoryGenerator.run()
    case "task_inventory": try TaskInventoryGenerator.run()
    default: throw UsageError.IncorrectUsage(usage)
    }
  }
}