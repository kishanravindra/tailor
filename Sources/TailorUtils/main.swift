/**
  This type parses the first argument and dispatches an appropriate command.
  */
struct ArgumentParser {
  static let usage = "- TailorUtils generate [options]"
  static func run() throws {
    if Process.arguments.count < 2 { throw UsageError.IncorrectUsage(self.usage) }
    switch(Process.arguments[1]) {
      case "generate": try Generator.run()
      default: throw UsageError.IncorrectUsage(self.usage)
    }
  }
}

do {
  try ArgumentParser.run()
}
catch let UsageError.IncorrectUsage(message) {
  print("Usage:\n\(message)")
}
catch let error {
  print("Error running script: \(error)")
}