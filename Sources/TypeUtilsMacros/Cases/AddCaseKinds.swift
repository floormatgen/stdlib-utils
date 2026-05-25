import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftSyntaxBuilder
import SwiftBasicFormat

public struct AddCaseKinds: MemberMacro {
  
  static let macroName = "AddCaseKinds"
  
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
    var kindEnumDecl = EnumDeclSyntax(name: kindEnumName, cases: cases)
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
            identifier: .identifier(kindPropertyName),
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
    
    // Add access modifiers if needed
    if let accessModifier, accessModifier.name.tokenKind != .keyword(.private) {
      kindEnumDecl.modifiers.insert(accessModifier, at: kindEnumDecl.modifiers.startIndex)
      kindProperty.modifiers.insert(accessModifier, at: kindProperty.modifiers.startIndex)
    }
    
    return [
      DeclSyntax(kindEnumDecl),
      DeclSyntax(kindProperty),
    ]
  }
  
}
