package import SwiftSyntax
import SwiftSyntaxMacros

package struct FunctionAnalysis {
  package var isAsync: Bool
  package var localFunctionNames: Set<TokenSyntax> 

  package init(from decl: FunctionDeclSyntax) {
    let signature = decl.signature

    // Function Effects
    let effects = signature.effectSpecifiers
    let isAsync = effects?.asyncSpecifier != nil

    // Closure Parameters
    // This handles function parameters, like for with-style methods
    let parameters = signature.parameterClause.parameters
    var localFunctionNames = Set<TokenSyntax>()

    let typeVisitor = TypeSyntaxVisitor(viewMode: .fixedUp)

    for parameter in parameters {

      // Check if the parameter contains a function
      guard typeVisitor.containsFunction(parameter.type) else {
        continue
      }

      // If a second name is provided (internal to function), use that instead
      if let secondName = parameter.secondName {
        localFunctionNames.insert(secondName)
      } else {
        localFunctionNames.insert(parameter.firstName)
      }
      
    }

    self.isAsync = isAsync
    self.localFunctionNames = localFunctionNames
  }

}

// MARK: - Syntax Visitors

extension FunctionAnalysis {

  final class TypeSyntaxVisitor: SyntaxVisitor {
    private var isFunction: Bool = false

    func containsFunction(_ syntax: some SyntaxProtocol) -> Bool {
      self.isFunction = false
      self.walk(syntax)
      return isFunction
    }

    override func visitPost(_ node: FunctionTypeSyntax) {
      isFunction = true
    }

  }

}
