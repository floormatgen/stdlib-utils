import SwiftSyntax

internal final class GlobalMacroChecker: SyntaxVisitor {
  private var containsGlobalMacro: Bool = false
  let macroName: String
  
  init(macroName: String) {
    self.macroName = macroName
    super.init(viewMode: .sourceAccurate)
  }
  
  func checkGlobalMacroUsed(in node: AttributeSyntax) -> Bool {
    containsGlobalMacro = false
    walk(node.attributeName)
    return containsGlobalMacro
  }
  
  override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
    if node.name.text == macroName {
      containsGlobalMacro = true
      return .skipChildren
    }
    return .visitChildren
  }
  
  override func visit(_ node: MemberTypeSyntax) -> SyntaxVisitorContinueKind {
    if node.name.text == macroName {
      containsGlobalMacro = true
      return .skipChildren
    }
    return .visitChildren
  }
  
}
