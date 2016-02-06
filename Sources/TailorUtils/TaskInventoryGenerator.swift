/**
  This type provides a command for generating an inventory of the tasks defined
  in the application.
  */
struct TaskInventoryGenerator: TypeInventoryGenerator {
  static let typeName = "TaskType"
  static let fileSuffix = "Task"
}