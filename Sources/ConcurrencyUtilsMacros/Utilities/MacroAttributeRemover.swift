import SwiftSyntax

extension AttributeListSyntax {
  
  func excludingMacro(withName name: String) -> Self {
    let visitor = MacroExcludingVisitor(macroName: name, moduleName: Plugin.hostingModuleName)
    return self.filter { element in
      guard let attribute = element.as(AttributeSyntax.self) else { return true }
      return !visitor.shouldRemove(attribute)
    }
  }
  
  mutating func excludeMacro(withName name: String) {
    self = excludingMacro(withName: name)
  }
  
}

// MARK: - Syntax Visitor

private final class MacroExcludingVisitor: SyntaxVisitor {
  let macroName: String
  let moduleName: String
  
  var macroToken: TokenSyntax   { .identifier(macroName)  }
  var moduleToken: TokenSyntax  { .identifier(moduleName) }
  
  private var shouldRemove: Bool = false
  
  init(macroName: String, moduleName: String) {
    self.macroName = macroName
    self.moduleName = moduleName
    super.init(viewMode: .sourceAccurate)
  }
  
  func shouldRemove(_ attribute: AttributeSyntax) -> Bool {
    shouldRemove = false
    self.walk(attribute)
    return shouldRemove
  }
  
  override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {

    // Ignore other attributes with the same name
    guard node.name.text == macroToken.text else { return .skipChildren }
    
    // If a module selector is used, make sure it is the same module
    if let module = node.moduleSelector {
      guard module.moduleName.text == moduleToken.text else { return .skipChildren }
    }
    
    // Mark for removal
    shouldRemove = true
    return .skipChildren
  }
  
  override func visit(_ node: MemberTypeSyntax) -> SyntaxVisitorContinueKind {
    
    // If the module is different, ignore the attribute
    // The macro can only be qualified by the Module name
    guard node.name.text == macroToken.text else {
      return .skipChildren
    }
    
    guard let baseIdentifier = node.baseType.as(IdentifierTypeSyntax.self),
          baseIdentifier.name.text == moduleToken.text else {
      return .skipChildren
    }
          
    
    // Otherwise delete the node
    shouldRemove = true
    return .skipChildren
  }
  
}
