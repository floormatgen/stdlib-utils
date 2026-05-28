package enum CompilerSupport {

  package static var nonisolatedNonsending: Bool {
    #if compiler(>=6.2)
    true
    #else
    false
    #endif
  }
  
  package static var concurrentAttribute: Bool {
    #if compiler(>=6.2)
    true
    #else
    false
    #endif
  }

  package static var bestIsolationStrategy: IsolationStrategy {
    if nonisolatedNonsending {
      .nonisolatedNonsending
    } else {
      .isolatedParameter
    }
  }

  package enum IsolationStrategy {
    case isolatedParameter
    case nonisolatedNonsending
    case none
  }

}
