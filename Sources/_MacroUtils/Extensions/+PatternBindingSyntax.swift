public import SwiftSyntax

extension PatternBindingSyntax {
  
  public func attemptToResolveType() -> TypeSyntax? {
    
    // Check if a type annotation is present
    if let typeAnnotation = self.typeAnnotation {
      // If a type annotation is provided, then return that type
      return typeAnnotation.type
    }
    
    // Otherwise try to guess the type from the initializer expression
    if let initExpr = initializer?.value {
      return _guessType(from: initExpr)
    }
    
    return nil
  }
  
}

// MARK: - Guessing Type from init expression

/// Attempt to infer the type from an expression, usind just the `AST` of the expression.
/// The inferred type may be incorrect.
///
/// - Parameters:
///   - exprSyntax: The expression to analyse
///
/// - Returns:
///   The `TypeSyntax` of the expression or `nil` if it could not be inferred
private func _guessType(from exprSyntax: ExprSyntax) -> TypeSyntax? {
  
  func swiftTypeSyntax(_ name: String) -> TypeSyntax {
    TypeSyntax(IdentifierTypeSyntax(name: .identifier(name)))
  }
  
  // Switch over available expressions
  switch exprSyntax.as(ExprSyntaxEnum.self) {
    
    // MARK: Literals
  case .booleanLiteralExpr:
    return swiftTypeSyntax("Bool")
  case .stringLiteralExpr, .simpleStringLiteralExpr:
    return swiftTypeSyntax("String")
  case .integerLiteralExpr:
    return swiftTypeSyntax("Int")
  case .floatLiteralExpr:
    return swiftTypeSyntax("Double")
    
    // Too complex to infer
  case .regexLiteralExpr, .nilLiteralExpr:
    return nil
    
    // TODO: Handle other literals
  default:
    return nil
  }
  
}
