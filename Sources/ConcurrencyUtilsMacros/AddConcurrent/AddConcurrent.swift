public import SwiftSyntax
public import SwiftSyntaxMacros
import SwiftDiagnostics
import _MacroUtils

public struct AddConcurrent: PeerMacro {
  
  static let name = "CustomAddConcurrent"
  static let globalName = "AddConcurrent"
  static let defaultConcurrentSuffix = "Concurrently"

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
    
    // Get options from the attribute
    let options = try Options(from: node)

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
    
    // Handle underscored first names with no second name
    // We can't refer to these arguments without a second name
    var modifiedSignature = functionDeclaration.signature
    for i in modifiedSignature.parameterClause.parameters.indices {
      var parameter = modifiedSignature.parameterClause.parameters[i]
      guard parameter.firstName.tokenKind == .wildcard, parameter.secondName == nil else { continue }
      
      // Generate a custom second name for the parameter
      parameter.secondName = context.makeUniqueName(parameter.firstName.text)
      
      modifiedSignature.parameterClause.parameters[i] = parameter
    }
    
    // Create the function body
    let callExpr = functionCallExpression(using: modifiedSignature, withName: functionDeclaration.name.text)
    let codeBlock = CodeBlockSyntax(
      statements: [
        CodeBlockItemSyntax(item: .expr(callExpr))
      ]
    )
    
    // Create the new concurrent function
    var newDecl = functionDeclaration
    
    // Remove the @AddConcurrent macro from the copy
    newDecl.attributes.excludeMacro(
      withName: options.isGlobal ? Self.globalName : Self.name, 
      moduleName: Plugin.moduleName
    )
    // Replace the body with the forwarding one
    newDecl.body = codeBlock
    // Replace the signature if needed
    newDecl.signature = modifiedSignature
    // Add `async` if needed
    newDecl.signature.effectSpecifiers.addAsync()
    // Remove `nonisolated(nonsending)` as it conflicts with `@concurrent`
    #if canImport(SwiftSyntax602)
    newDecl.modifiers.removeNonisolatedNonsending()
    #endif // canImport(SwiftSyntax602)

    // Replace the name
    if let customName = options.name {
      newDecl.name = .identifier(customName)
    } else {
      // Prefix "Concurrently" to the old name
      var (newName, didUnwrap) = RawIdentifiers.unwrapIdentifierIfNeeded(newDecl.name.text)
      newName.append(contentsOf: Self.defaultConcurrentSuffix)
      newDecl.name = didUnwrap
        ? .identifier(RawIdentifiers.wrapIdentifier(newName))
        : .identifier(newName)
    }
    
    // Add @concurrent if it is supported
    if CompilerSupport.concurrentAttribute {
      let concurrent = Common.Attributes.concurrent
      newDecl.attributes.append(.attribute(concurrent))
    }
    
    return [
      DeclSyntax(newDecl)
    ]
  }

  private static func functionCallExpression(
    using signature: FunctionSignatureSyntax,
    withName name: String
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
    
    // Build the function call expression
    var parameterList = LabeledExprListSyntax()
    for parameter in signature.parameterClause.parameters {
      let firstName = parameter.firstName
      
      // Account for the use of a wildcard
      let label: TokenSyntax?
      if firstName.tokenKind == .wildcard {
        label = nil
      } else {
        label = firstName.trimmed
      }
      
      // Get the correct name for the second value
      let value: TokenSyntax
      if let secondName = parameter.secondName {
        value = secondName.trimmed
      } else {
        // We should have already taken care of the case
        // where there is no second name when the first name is _
        value = label!
      }
      
      // Add each argument to the parameter list
      parameterList.append(
        LabeledExprSyntax(
          label: label,
          colon: label != nil ? .colonToken() : nil,
          expression: DeclReferenceExprSyntax(
            baseName: value
          ),
          trailingComma: .commaToken()
        )
      )
    }
    
    // Remove trailing comma if it exists
    if var lastArg = parameterList.last {
      lastArg.trailingComma = nil
      parameterList[parameterList.index(before: parameterList.endIndex)] = lastArg
    }
    
    // Create the call expression
    let funcRef = DeclReferenceExprSyntax(baseName: .identifier(name))
    
    var callExpr = ExprSyntax(
      FunctionCallExprSyntax(
        calledExpression: funcRef,
        leftParen: .leftParenToken(),
        arguments: parameterList,
        rightParen: .rightParenToken()
      )
    )
    
    // Handle async
    if isAsync {
      callExpr = ExprSyntax(
        AwaitExprSyntax(expression: callExpr)
      )
    }
    
    // Handle throws
    if isThrowing {
      callExpr = ExprSyntax(
        TryExprSyntax(expression: callExpr)
      )
    }
    
    return callExpr
  }
  
}
