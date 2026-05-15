import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

package enum FunctionDiagnostic {

  package static func notAFunction(decl: some DeclSyntaxProtocol) -> Diagnostic {
    assert(!decl.is(FunctionDeclSyntax.self))
    return Diagnostic(
      node: decl, 
      message: MacroExpansionErrorMessage("Must be applied to a function")
    )
  }

  package static func alreadyAsync(decl: FunctionDeclSyntax) -> Diagnostic {
    Diagnostic(
      node: decl,
      message: MacroExpansionErrorMessage("Function is already marked async")
    )
  }

  package static func noClosureParameters(decl: FunctionDeclSyntax) -> Diagnostic {
    Diagnostic(
      node: decl,
      message: MacroExpansionWarningMessage("No function parameters detected, adding this macro does nothing")
    )
  }

  package static func alreadyMarkedConcurrent(decl: FunctionDeclSyntax) -> Diagnostic {
    Diagnostic(
      node: decl, 
      message: MacroExpansionErrorMessage("Function is already marked as @concurrent")
    )
  }

}
