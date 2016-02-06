/**
  This enum provides errors when running commands.
  */
enum UsageError: ErrorType {
  /**
    This error is thrown when the user tries to invoke a command that is not
    supported or has other syntax problems.
    */
  case IncorrectUsage(String)
}