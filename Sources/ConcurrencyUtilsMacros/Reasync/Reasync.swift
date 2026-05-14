import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct Reasync: PeerMacro {
  static let name = "Reasync"
  static let diagnosticMessageID = MessageID(domain: Plugin.moduleName, id: Reasync.name)

  public static var formatMode: FormatMode {
    .auto
  }
  
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    
    // Make sure this attribute is on a function
    // Other declarations cannot be marked asyn
    guard let functionDeclSyntax = declaration.as(FunctionDeclSyntax.self) else {
      context.diagnose(FunctionDiagnostic.notAFunction(decl: declaration))
      return []
    }

    // Make sure the function is not already async
    let analysis = FunctionAnalysis(from: functionDeclSyntax)
    guard !analysis.isAsync else {
      context.diagnose(FunctionDiagnostic.alreadyAsync(decl: functionDeclSyntax))
      return []
    }

    // Check if there are any closure parameters to modify
    // If there aren't this is probably a mistake by the user
    if analysis.localFunctionNames.isEmpty {
      context.diagnose(FunctionDiagnostic.noClosureParameters(decl: functionDeclSyntax))
    }
    
    // Get the options from the reasync attribute
    let options = try Options(from: node)

    // Make a copy of the function declaration for the async alternative
    let asyncFunctionDecl = try asyncFunctionDecl(from: functionDeclSyntax, analysis: analysis, options: options)

    return [
      DeclSyntax(asyncFunctionDecl)
    ]

  }

  private static func asyncFunctionDecl(
    from functionDecl: FunctionDeclSyntax,
    analysis: FunctionAnalysis,
    options: Options
  ) throws -> FunctionDeclSyntax {
    var asyncFunctionDecl = functionDecl
    
    // Remove the AsyncAlternative Macro
    asyncFunctionDecl.attributes = asyncFunctionDecl.attributes.excludingMacro(withName: name)
    
    // Choose the best isolation control supported
    let isolationStrategy = CompilerSupport.bestIsolationStrategy
    switch isolationStrategy {
      case .nonisolatedNonsending:
        addNonisolatedNonsending(to: &asyncFunctionDecl.modifiers)
      case .isolatedParameter:
        // TODO: Add "isolation: isolated (any Actor)? = #isolation"
        break
      case .none:
        break
    }
    
    // Add async specifier to function
    var effects = asyncFunctionDecl.signature.effectSpecifiers ?? FunctionEffectSpecifiersSyntax(throwsClause: nil)
    effects.asyncSpecifier = .keyword(.async)
    asyncFunctionDecl.signature.effectSpecifiers = effects

    // Add async specifiers to function parameters
    addAsyncSpecifiers(to: &asyncFunctionDecl.signature.parameterClause.parameters, isolationStrategy: isolationStrategy)
    
    // Update the name if required
    if let newName = options.name {
      asyncFunctionDecl.name = .identifier(newName)
    }
    
    // Rewrite function body
    if var body = asyncFunctionDecl.body {
      let rewriter = FunctionBodySyntaxRewriter(localFunctionNames: analysis.localFunctionNames)
      body = rewriter.rewrite(body).as(CodeBlockSyntax.self)!
      asyncFunctionDecl.body = body
    }

    return asyncFunctionDecl
  }
  
}

// MARK: - Helpers

private func addNonisolatedNonsending(to modifierList: inout DeclModifierListSyntax) {

  // Check if nonisolated is already a modifier
  let nonisolatedToken = TokenSyntax(.keyword(.nonisolated), presence: .present)
  let nonsendingDetail = DeclModifierDetailSyntax(detail: TokenSyntax(.keyword(.nonsending), presence: .present))

  for i in modifierList.indices where modifierList[i].name.text == nonisolatedToken.text {
    // If it exists, we add the nonsending detail
    modifierList[i].detail = nonsendingDetail
    return
  }

  // Otherwise add nonisolated(nonsending) to the list
  let nonisolatedNonsending = DeclModifierSyntax(name: nonisolatedToken, detail: nonsendingDetail)
  modifierList.append(nonisolatedNonsending)

}

private func addAsyncSpecifiers(
  to parameters: inout FunctionParameterListSyntax, 
  isolationStrategy: CompilerSupport.IsolationStrategy
) {
  let rewriter = FunctionParameterSyntaxRewriter(isolationStrategy: isolationStrategy)
  let newParameters = rewriter.rewrite(parameters)
  parameters = newParameters.as(FunctionParameterListSyntax.self)!
}

// MARK: - Syntax Rewriters

private final class FunctionParameterSyntaxRewriter: SyntaxRewriter {
  let isolationStrategy: CompilerSupport.IsolationStrategy

  private var isFunction: Bool = false
  private var willAddAttribute: Bool = false

  init(isolationStrategy: CompilerSupport.IsolationStrategy) {
    self.isolationStrategy = isolationStrategy
  }
  
  override func visit(_ node: FunctionParameterSyntax) -> FunctionParameterSyntax {
    isFunction = false
    willAddAttribute = false
    return super.visit(node)
  }
  
  override func visit(_ node: AttributedTypeSyntax) -> TypeSyntax {
    isFunction = false
    willAddAttribute = true
    guard var rewritten = super.visit(node).as(AttributedTypeSyntax.self) else {
      preconditionFailure("\(#function): Unexpected conversion away from AttributedTypeSyntax")
    }
    
    // Check if the attributed type wraps a function
    guard isFunction else { return TypeSyntax(rewritten) }
    
    // Add specifier
    addNonisolatedNonsending(to: &rewritten.specifiers)
    return TypeSyntax(rewritten)
  }

  override func visit(_ node: FunctionTypeSyntax) -> TypeSyntax {
    isFunction = true
    var modifiedNode = node

    // Add async specifier
    var effectSpecifiers = modifiedNode.effectSpecifiers ?? TypeEffectSpecifiersSyntax(throwsClause: nil)
    effectSpecifiers.asyncSpecifier = TokenSyntax(.keyword(.async), presence: .present)
    modifiedNode.effectSpecifiers = effectSpecifiers
    
    // Check if we need to add attributes
    guard !willAddAttribute else { return TypeSyntax(modifiedNode) }
    var specifierList = TypeSpecifierListSyntax()
    addNonisolatedNonsending(to: &specifierList)
    let attributedType = AttributedTypeSyntax(specifiers: specifierList, baseType: modifiedNode)
    return TypeSyntax(attributedType)
  }
  
  private func addNonisolatedNonsending(to typeSpecifierList: inout TypeSpecifierListSyntax) {
    
    let nonsending = NonisolatedSpecifierArgumentSyntax()
    
    // If there is already a nonisolated specifier, add nonsending
    for i in typeSpecifierList.indices where typeSpecifierList[i].is(NonisolatedTypeSpecifierSyntax.self) {
      var nonisolatedTypeSpecifier = typeSpecifierList[i].as(NonisolatedTypeSpecifierSyntax.self)!
      nonisolatedTypeSpecifier.argument = nonsending
      typeSpecifierList[i] = .nonisolatedTypeSpecifier(nonisolatedTypeSpecifier)
      return
    }
    
    // Otherwise add a new specifier
    let nonsendingSpecifier = NonisolatedTypeSpecifierSyntax(argument: nonsending)
    typeSpecifierList.append(.nonisolatedTypeSpecifier(nonsendingSpecifier))
    
  }

}

private final class FunctionBodySyntaxRewriter: SyntaxRewriter {
  let localFunctionNames: Set<TokenSyntax>
  private let localFunctionTexts: Set<String>
  
  private var didAccessMember: Bool = false
  private var lastDeclReferenceIdentifierText: String = ""
  
  init(localFunctionNames: Set<TokenSyntax>) {
    self.localFunctionNames = localFunctionNames
    self.localFunctionTexts = Set(localFunctionNames.map(\.text))
  }
  
  override func visit(_ node: FunctionCallExprSyntax) -> ExprSyntax {
    
    // Make sure member access did not occur
    didAccessMember = false
    guard let rewritten = super.visit(node).as(FunctionCallExprSyntax.self) else {
      preconditionFailure("\(#function): Unexpected conversion away from FunctionCallExprSyntax")
    }
    guard !didAccessMember else {
      return ExprSyntax(rewritten)
    }
    
    // Check if we match a known local function
    guard let functionCallDeclReference = rewritten.calledExpression.as(DeclReferenceExprSyntax.self),
          localFunctionTexts.contains(functionCallDeclReference.baseName.text) else {
      return ExprSyntax(rewritten)
    }
    
    // If we do, wrap the call in an 'await'
    var awaitExpr = AwaitExprSyntax(expression: node)
    awaitExpr.leadingTrivia = node.leadingTrivia
    awaitExpr.expression.leadingTrivia = .spaces(1)
    return ExprSyntax(awaitExpr)
  }
  
  override func visit(_ node: AwaitExprSyntax) -> ExprSyntax {
    // We don't need to reannotate things with await
    return ExprSyntax(node)
  }
  
  override func visit(_ node: MemberAccessExprSyntax) -> ExprSyntax {
    // Make sure we don't add await to other unrelated functions
    didAccessMember = true
    return super.visit(node)
  }
  
}
