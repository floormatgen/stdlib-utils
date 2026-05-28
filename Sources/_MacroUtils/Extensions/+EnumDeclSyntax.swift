public import SwiftSyntax

extension EnumDeclSyntax {
  
  public func getCaseElements() -> [EnumCaseElementSyntax] {
    var cases: [EnumCaseElementSyntax] = []
    
    for member in memberBlock.members {
      guard let enumCaseDecl = member.decl.as(EnumCaseDeclSyntax.self) else { continue }
      for var element in enumCaseDecl.elements {
        element.trailingComma = nil
        cases.append(element)
      }
    }
    
    return cases
  }
  
  public init(
    attributes: AttributeListSyntax = [],
    modifiers: DeclModifierListSyntax = [],
    name: String,
    cases: some Sequence<EnumCaseElementSyntax>
  ) {
    let caseDecls = cases.map { EnumCaseDeclSyntax(elements: [$0]) }
    var memberBlockItems = MemberBlockItemListSyntax()
    for caseDecl in caseDecls {
      memberBlockItems.append(MemberBlockItemSyntax(decl: caseDecl))
    }
    self.init(
      attributes: attributes,
      modifiers: modifiers,
      name: .identifier(name),
      memberBlock: MemberBlockSyntax(members: memberBlockItems)
    )
  }
  
}
