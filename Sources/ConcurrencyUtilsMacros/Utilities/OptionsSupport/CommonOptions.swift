import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftParser

package enum CommonOptions {
  
  static let named = "named"
  
  static func named(from labeledExpr: LabeledExprSyntax) throws -> String {
    precondition(labeledExpr.label?.text == "named")
    
    // Make sure the name is provided as a string literal
    guard
      let nameLiteral = labeledExpr.expression.as(StringLiteralExprSyntax.self),
      let resolvedName = nameLiteral.representedLiteralValue
    else {
      throw Error.nameNotValidStringLiteral(node: labeledExpr)
    }
    
    return resolvedName
  }
  
}

// MARK: - Errors

extension CommonOptions {
  
  package enum Error {
    
    static func nameNotValidStringLiteral(node: some SyntaxProtocol) -> DiagnosticsError {
      DiagnosticsError(diagnostics: [
        Diagnostic(
          node: node,
          message: MacroExpansionErrorMessage("Custom name must be a valid string literal")
        )
      ])
    }
    
  }
  
}
