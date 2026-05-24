import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

struct Cases: MemberMacro {
  
  static let macroName = "Cases"
  
  static var formatMode: FormatMode {
    .auto
  }
  
  static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    
    // Make sure this is attached to an enum
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      context.diagnose(
        Diagnostic(
          node: declaration,
          message: MacroExpansionErrorMessage("This macro can only be applied to enums")
        )
      )
      return []
    }
    
    return []
  }
  
}
