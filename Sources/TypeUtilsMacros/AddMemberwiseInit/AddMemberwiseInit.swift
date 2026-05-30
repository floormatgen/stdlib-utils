public import SwiftSyntax
public import SwiftSyntaxMacros

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
    return []
  }
  
}
