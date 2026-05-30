public import SwiftSyntax
public import SwiftSyntaxMacros
import SwiftDiagnostics

public struct AddMemberwiseInit: MemberMacro {
  
  public static var formatMode: FormatMode {
    .auto
  }
  
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    
    // Make sure we are not attached to an enum or extension
    // We cannot infer stored properties from an extension
    guard !declaration.is(EnumDeclSyntax.self) else {
      context.diagnose(
        Diagnostic(
          node: declaration,
          message: MacroExpansionErrorMessage("Cannot add memberwise initializer to enum")))
      return []
    }
    guard !declaration.is(ExtensionDeclSyntax.self) else {
      context.diagnose(
        Diagnostic(
          node: declaration,
          message: MacroExpansionErrorMessage("Cannot infer stored properties from an extension decleration")))
      return []
    }
    
    // Get stored properties
    let memberBlock      = declaration.memberBlock
    let storedProperties = memberBlock.members.getNonlazyStoredProperties()
    
    return []
  }
  
}

// MARK: - Extract Stored Properties

private extension MemberBlockItemListSyntax {
  
  func getNonlazyStoredProperties() -> [VariableDeclSyntax] {
    var storedProperties: [VariableDeclSyntax] = []
    
    memberLoop: for memberItem in self {
      guard let variableDecl = memberItem.decl.as(VariableDeclSyntax.self) else { continue }
      
      // Make sure it doesn't contain lazy
      let modifiers = variableDecl.modifiers
      for modifier in modifiers {
        if modifier.name.tokenKind == .keyword(.lazy) {
          continue memberLoop
        }
      }
      
      // TODO: Make sure it is not computed
      
      storedProperties.append(variableDecl)
    }
    
    return storedProperties
  }
  
}
