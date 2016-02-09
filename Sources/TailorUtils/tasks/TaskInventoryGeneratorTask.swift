/**
  This type provides a command for generating an inventory of the tasks defined
  in the application.
  */
final class TaskInventoryGeneratorTask: TypeInventoryGenerator {
  static let typeName = "TaskType"
  static let fileSuffix = "Task"
  static let commandName = "task_inventory"
  var fileContents = ""
  var fileIndentation = 0
}