internal enum CompilerSupport {

  static var nonisolatedNonsending: Bool {
    #if compiler(>=6.2)
    true
    #else
    false
    #endif
  }

  static var bestIsolationStrategy: IsolationStrategy {
    if nonisolatedNonsending {
      .nonisolatedNonsending
    } else {
      .isolatedParameter
    }
  }

  enum IsolationStrategy {
    case isolatedParameter
    case nonisolatedNonsending
    case none
  }

}
