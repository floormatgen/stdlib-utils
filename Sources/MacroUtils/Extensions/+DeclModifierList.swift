import SwiftSyntax

extension DeclModifierListSyntax {
  
  public var accessModifier: DeclModifierSyntax? {
    for modifier in self {
      guard case .keyword(let keyword) = modifier.name.tokenKind else { continue }
      
      // Check if the keyword is an access modifier
      switch keyword {
      case .private, .fileprivate, .internal, .package, .public:
        return modifier
      default:
        continue
      }
      
    }
    
    // If we reach this point, there is no access modifier
    return nil
  }
  
}
