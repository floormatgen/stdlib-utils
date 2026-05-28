public import SwiftSyntax
public import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftBasicFormat
import _MacroUtils

public struct AddCaseKind: MemberMacro {
  
  static let macroName    = "AddCaseKind"
  static let protocolName = "CaseKindProvider"
  
  public static var formatMode: FormatMode {
    .auto
  }
  
  public static func expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    
    // Make sure this is attached to an enum
    guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
      context.diagnose(
        Diagnostic(
          node: declaration,
          message: MacroExpansionErrorMessage("This macro can only be applied to enums")
        )
      )
      return []
    }
    
    // Get access modifier for enum
    let accessModifier = enumDecl.modifiers.accessModifier
    
    // Get all cases from the enum
    var cases = enumDecl.getCaseElements()
    // Remove enum parameters
    for i in cases.indices {
      cases[i].parameterClause = nil
    }
    
    // MARK: Nested Kind enum
    let kindEnumName = "Kind"
    
    // Create nested kind enum
    var kindEnumDecl = EnumDeclSyntax(
      attributes: enumDecl.attributes,
      modifiers: enumDecl.modifiers,
      name: kindEnumName,
      cases: cases
    )
    // Add conformances to Sendable, Equatable, Hashable
    kindEnumDecl.inheritanceClause = InheritanceClauseSyntax(
      inheritedTypes: [
        InheritedTypeSyntax(type: Common.Protocols.Sendable,  trailingComma: .commaToken()),
        InheritedTypeSyntax(type: Common.Protocols.Equatable, trailingComma: .commaToken()),
        InheritedTypeSyntax(type: Common.Protocols.Hashable),
      ]
    )
    
    // MARK: Add kind property to hosting enum
    let kindPropertyName = "kind"
    
    // Generate switch statement handling each case
    var switchCases = SwitchCaseListSyntax()
    for c in cases {
      let trimmedName = c.name.trimmed
      
      // Generate case expression for each
      let switchCase: SwitchCaseSyntax = """
        case .\(trimmedName):
            return .\(trimmedName)
        """
      
      // Add it to the list
      switchCases.append(.switchCase(switchCase))
    }
    
    // Create the switch statement
    let switchExpr = SwitchExprSyntax(
      subject: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
      cases: switchCases
    )
    
    // Create kind property
    var kindProperty = VariableDeclSyntax(
      bindingSpecifier: .keyword(.var),
      bindings: [
        PatternBindingSyntax(
          pattern: IdentifierPatternSyntax(
            identifier: .identifier(kindPropertyName)
          ),
          typeAnnotation: TypeAnnotationSyntax(
            type: IdentifierTypeSyntax(
              name: .identifier(kindEnumName)
            )
          ),
          accessorBlock: AccessorBlockSyntax(
            accessors: .getter([
              CodeBlockItemSyntax(item: .expr(ExprSyntax(switchExpr)))
            ])
          )
        )
      ]
    )
    
    // MARK: Access Control, modifier and attribute handling
    
    // Add access modifiers if needed to variable
    if let accessModifier, accessModifier.name.tokenKind != .keyword(.private) {
      kindProperty.modifiers.insert(accessModifier, at: kindProperty.modifiers.startIndex)
    }
    
    // Remove private and indirect modifier from Kind enum if exists
    kindEnumDecl.modifiers = kindEnumDecl.modifiers.filter { modifier in
      return !(
        modifier.name.tokenKind == .keyword(.private) ||
        modifier.name.tokenKind == .keyword(.indirect)
      )
    }
    
    // Remove macro from copied attributes
    kindEnumDecl.attributes.excludeMacro(withName: macroName, moduleName: Plugin.moduleName)
    
    return [
      DeclSyntax(kindEnumDecl),
      DeclSyntax(kindProperty),
    ]
  }
  
}

// MARK: - Extension

extension AddCaseKind: ExtensionMacro {
  
  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {
    
    let caseKindProviderType = MemberTypeSyntax(
      baseType: IdentifierTypeSyntax(
        name: .identifier(Plugin.moduleName)
      ),
      name: .identifier(protocolName)
    )
    
    let caseKindProviderExtension = ExtensionDeclSyntax(
      extendedType: TypeSyntax(type),
      inheritanceClause: InheritanceClauseSyntax(
        inheritedTypes: [
          InheritedTypeSyntax(type: caseKindProviderType)
        ]
      ),
      memberBlock: MemberBlockSyntax(
        members: []
      )
    )
    
    return [
      caseKindProviderExtension
    ]
  }
  
}
