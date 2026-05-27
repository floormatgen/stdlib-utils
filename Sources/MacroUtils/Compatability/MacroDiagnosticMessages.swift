import SwiftSyntax
import SwiftDiagnostics

#if !canImport(SwiftSyntax600)
private let diagnosticDomain = "SwiftSyntaxMacros"

package struct MacroExpansionErrorMessage: DiagnosticMessage {

  package var diagnosticID: MessageID {
    MessageID(domain: diagnosticDomain, id: "\(Self.self)")
  }

  package var severity: DiagnosticSeverity { .error }

  package let message: String

  package init(_ message: String) {
    self.message = message
  }

}

package struct MacroExpansionWarningMessage: DiagnosticMessage {

  package var diagnosticID: MessageID {
    MessageID(domain: diagnosticDomain, id: "\(Self.self)")
  }

  package var severity: DiagnosticSeverity { .error }

  package let message: String

  package init(_ message: String) {
    self.message = message
  }

}
#endif // !canImport(SwiftSyntax600)
