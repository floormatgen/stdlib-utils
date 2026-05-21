import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftDiagnostics

public struct AddTypeEraser: PeerMacro {
  
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    
    // Ensure it is applied to a protocol decleration
    guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else {
      context.diagnose(
        Diagnostic(
          node: declaration,
          message: MacroExpansionErrorMessage("Must be on a protocol declaration")
        )
      )
      return []
    }
    
    // TODO: Support actors when assumeIsolated(_:file:line:) adopts typed throws
    // Make sure the protocol is not constrained to an Actor
    guard protocolDecl.typeConstraint != .Actor else {
      context.diagnose(
        Diagnostic(
          node: declaration,
          message: MacroExpansionErrorMessage("Actors not currently supported")
        )
      )
      return []
    }
    
    // Get the new name for the type eraser
    let (protocolName, shouldWrap) = RawIdentifiers.unwrapIdentifierIfNeeded(protocolDecl.name.text)
    var typeEraserName = "Any\(protocolName)"
    if shouldWrap {
      typeEraserName = RawIdentifiers.wrapIdentifier(typeEraserName)
    }
    
    // Generate members for the type
    let members     = typeEraserMembers(for: protocolDecl)
    let memberBlock = MemberBlockSyntax(members: members)
    // Get access level
    let accessModifier = protocolDecl.modifiers.accessModifier
    
    // Inheritance clause for protocol conformance
    let inheritanceClause = InheritanceClauseSyntax(
      inheritedTypes: [
        InheritedTypeSyntax(
          type: IdentifierTypeSyntax(name: .identifier(protocolName))
        )
      ]
    )
    
    // Choose the best containing type
    let typeEraserDecl: DeclSyntax
    switch protocolDecl.typeConstraint {
    case .Any:
      
      // Prefer to use a struct
      var structDecl = StructDeclSyntax(
        name: .identifier(typeEraserName),
        inheritanceClause: inheritanceClause,
        memberBlock: memberBlock
      )
      if let accessModifier {
        structDecl.modifiers.insert(accessModifier, at: structDecl.modifiers.startIndex)
      }
      typeEraserDecl = DeclSyntax(structDecl)
      
    case .AnyObject:
      
      // Use a final class if protocol is constrained to AnyObject
      var classDecl = ClassDeclSyntax(
        modifiers: [
          DeclModifierSyntax(name: .keyword(.final))
        ],
        name: .identifier(typeEraserName),
        inheritanceClause: inheritanceClause,
        memberBlock: memberBlock
      )
      if let accessModifier {
        classDecl.modifiers.insert(accessModifier, at: classDecl.modifiers.startIndex)
      }
      typeEraserDecl = DeclSyntax(classDecl)
      
    case .Actor:
      preconditionFailure("Actor not supported")
    }
    
    return [
      typeEraserDecl
    ]
  }
  
}

// MARK: - Generating Members

extension AddTypeEraser {
  
  internal static func typeEraserMembers(
    for protocolDecl: ProtocolDeclSyntax
  ) -> MemberBlockItemListSyntax {
    var members = MemberBlockItemListSyntax()
    
    // First get access modifier for the protocol
    let accessModifier = protocolDecl.modifiers.accessModifier
    // Get the protocol type constraint
    let typeConstraint = protocolDecl.typeConstraint
    
    // If the protocol is constrained to a class, use let instead
    let bindingSpecifier: TokenSyntax
    switch typeConstraint {
    case .Any:
      bindingSpecifier = .keyword(.var)
    case .AnyObject, .Actor:
      bindingSpecifier = .keyword(.let)
    }
    
    // Add init and base member
    let baseMember: DeclSyntax = """
      \(accessModifier)\(bindingSpecifier) base: any \(protocolDecl.name)
      """
    let initErasingMember: DeclSyntax = """
      \(accessModifier)init<T: \(protocolDecl.name.trimmed)>(erasing base: consuming T) {
          self.base = base
      }
      """
    let initMember: DeclSyntax = """
      \(accessModifier)init<T: \(protocolDecl.name.trimmed)>(_ base: consuming T) {
          self.base = base
      }
      """
    members.append(MemberBlockItemSyntax(decl: baseMember))
    members.append(MemberBlockItemSyntax(decl: initErasingMember))
    members.append(MemberBlockItemSyntax(decl: initMember))
    
    // TODO: Handle protocol requirements
    
    return members
  }
  
}
