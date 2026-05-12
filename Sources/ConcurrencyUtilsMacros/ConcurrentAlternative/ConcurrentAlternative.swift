import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ConcurrentAlternative: PeerMacro {

  public static var formatMode: FormatMode {
    .auto
  }

  public static func expansion(
    of node: AttributeSyntax, 
    providingPeersOf declaration: some DeclSyntaxProtocol, 
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {

    // Make sure that the attribute is on the function
    guard let functionDeclaration = declaration.as(FunctionDeclSyntax.self) else {
      context.diagnose(FunctionDiagnostic.notAFunction(decl: declaration))
      return []
    }

    // Make sure the function doesn't already have the @concurrent attribute
    let attributes = functionDeclaration.attributes
    for attribute in attributes {
      guard 
        let attribute = attribute.as(AttributeSyntax.self),
        let attributeIdentifier = attribute.attributeName.as(IdentifierTypeSyntax.self)
      else { 
        continue
      }

      if attributeIdentifier.name.tokenKind == .identifier("concurrent") {
        context.diagnose(FunctionDiagnostic.alreadyMarkedConcurrent(decl: functionDeclaration))
      }
    }

    return []
  }

  private static func functionCallExpression(
    using signature: FunctionSignatureSyntax
  ) -> ExprSyntax {

    // Check if the function is async or throwing
    let isAsync: Bool
    let isThrowing: Bool
    if let effectSpecifiers = signature.effectSpecifiers {
      isAsync     = effectSpecifiers.asyncSpecifier != nil
      isThrowing  = effectSpecifiers.throwsClause != nil
    } else {
      isAsync     = false
      isThrowing  = false
    }
    fatalError()
//    return ExprSyntax(FunctionCallExprSyntax)
  }
  
}
