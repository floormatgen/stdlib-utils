import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct AddTypeEraser: PeerMacro {
  
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    
    // Ensure it is applied to a protocol decleration
    guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
      context.diagnose(
        Diagnostic(
          node: declaration,
          message: MacroExpansionErrorMessage("Must be on a protocol declaration")
        )
      )
      return []
    }
    
    // Get the new name for the type eraser
    let (protocolName, shouldWrap) = RawIdentifiers.unwrapIdentifierIfNeeded(protocolDecl.name.text)
    var typeEraserName = "Any\(protocolName)"
    if shouldWrap {
      typeEraserName = RawIdentifiers.wrapIdentifier(typeEraserName)
    }
    
    
    
    return []
  }
  
}
