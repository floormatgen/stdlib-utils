import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

internal enum FunctionDiagnostic {

  static func notAFunction(decl: some DeclSyntaxProtocol) -> Diagnostic {
    assert(!decl.is(FunctionDeclSyntax.self))
    return Diagnostic(
      node: decl, 
      message: MacroExpansionErrorMessage("Must be applied to a function")
    )
  }

  static func alreadyAsync(decl: FunctionDeclSyntax) -> Diagnostic {
    Diagnostic(
      node: decl,
      message: MacroExpansionErrorMessage("Function is already marked async")
    )
  }

  static func noClosureParameters(decl: FunctionDeclSyntax) -> Diagnostic {
    Diagnostic(
      node: decl,
      message: MacroExpansionWarningMessage("No function parameters detected, adding this macro does nothing")
    )
  }

}
