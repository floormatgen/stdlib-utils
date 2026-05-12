import SwiftSyntax
import SwiftDiagnostics

// TODO: AsyncAlternative Options
/*

extension AsyncAlternative {

  struct Options {
    var dynamicIsolation: DynamicIsolation = .preferred

    init(from attribute: AttributeSyntax) throws {

      // Check if there are any options
      // Otherwise use defaults
      guard let arguments = attribute.arguments else { return }

      guard let list = arguments.as(LabeledExprListSyntax.self) else {
        throw Error.invalidArguments
      }

      // There should not be any labels
      var seenOptions = Set<String>()
      let expressionList = list.map(\.expression)
      for expression in expressionList {

        guard let memberRef = expression.as(MemberAccessExprSyntax.self) else {
          throw Error.variableReferencesNotAllowed
        }

      }

    }

  }

}

// MARK: - Options

extension AsyncAlternative.Options {

  enum DynamicIsolation: String {
    case preferred
    case nonisolatedNonsending
    case isolatedParameter
    case none
  }

}

// MARK: - Errors

extension AsyncAlternative.Options {

  enum Error: Swift.Error, DiagnosticMessage {
    case invalidArguments
    case duplicatedArguments(String)
    case variableReferencesNotAllowed

    var diagnosticID: MessageID {
      AsyncAlternative.diagnosticMessageID
    }

    var message: String {
      switch self {
        case .invalidArguments:
          "Could not read arguments"
        case .duplicatedArguments(let argument):
          "Conflicting options for \"\(argument)\""
        case .variableReferencesNotAllowed:
          "Option must be known at compile time. References are not allowed."
      }
    }

    var severity: DiagnosticSeverity {
      .error
    }
  }

}

*/
