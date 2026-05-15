import SwiftSyntax

package final class GlobalMacroChecker: SyntaxVisitor {
  private var containsGlobalMacro: Bool = false
  package let macroName: String
  
  package init(macroName: String) {
    self.macroName = macroName
    super.init(viewMode: .sourceAccurate)
  }
  
  package func checkGlobalMacroUsed(in node: AttributeSyntax) -> Bool {
    containsGlobalMacro = false
    walk(node.attributeName)
    return containsGlobalMacro
  }
  
  package override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
    if node.name.text == macroName {
      containsGlobalMacro = true
      return .skipChildren
    }
    return .visitChildren
  }
  
  package override func visit(_ node: MemberTypeSyntax) -> SyntaxVisitorContinueKind {
    if node.name.text == macroName {
      containsGlobalMacro = true
      return .skipChildren
    }
    return .visitChildren
  }
  
}
