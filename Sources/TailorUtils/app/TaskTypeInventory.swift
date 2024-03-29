import Tailor
extension Application.Configuration {
  func registerTasks() {
    TypeInventory.shared.registerSubtypes(TaskType.self, subtypes: [
      AlterationGeneratorTask.self,
      AlterationInventoryGeneratorTask.self,
      ControllerGeneratorTask.self,
      InventoryGeneratorTask.self,
      ModelGeneratorTask.self,
      TaskInventoryGeneratorTask.self,
      TemplateGeneratorTask.self,
    ])
  }
}
