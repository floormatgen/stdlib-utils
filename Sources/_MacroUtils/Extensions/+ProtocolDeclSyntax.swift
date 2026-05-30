public import SwiftSyntax

extension ProtocolDeclSyntax {
  
  public enum TypeConstraint: Sendable, LosslessStringConvertible, Comparable {
    case `Any`
    case AnyObject
    case Actor
    
    public static var `class`: TypeConstraint {
      .AnyObject
    }
    
    public var description: String {
      switch self {
      case .Any:
        return "Any"
      case .AnyObject:
        return "AnyObject"
      case .Actor:
        return "Actor"
      }
    }
    
    public init?(_ description: String) {
      switch description {
      case "Any":
        self = .Any
      case "AnyObject", "class":
        self = .AnyObject
      case "Actor":
        self = .Actor
      default:
        return nil
      }
    }
    
    public init?(from tokenSyntax: TokenSyntax) {
      self.init(tokenSyntax.text)
    }
    
    public var priority: Int {
      switch self {
      case .Any:
        return 0
      case .AnyObject:
        return 1
      case .Actor:
        return 2
      }
    }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
      return lhs.priority > rhs.priority
    }
    
    public mutating func formIntersection(_ other: TypeConstraint) {
      if other < self {
        self = other
      }
    }
    
  }
  
  public var typeConstraint: TypeConstraint {
    var strictest = TypeConstraint.Any
    
    // Get protocol connstraints
    guard let constraints = self.inheritanceClause?.inheritedTypes else {
      return strictest
    }
    
    let swiftModuleName = "Swift"
    #if canImport(SwiftSyntax603)
    func isSwiftModuleSelector(_ moduleSelector: ModuleSelectorSyntax) -> Bool {
      moduleSelector.moduleName.text == swiftModuleName
    }
    #endif // canImport(SwiftSyntax630) 
    
    // Check each constraint
    for constraint in constraints {
      if let memberType = constraint.type.as(MemberTypeSyntax.self) {
        
        // Only check if the type belongs to the Swift module
        guard
          let baseType = memberType.baseType.as(IdentifierTypeSyntax.self),
          baseType.name.text == swiftModuleName
        else {
          continue
        }
        
        // Make sure the module selector refers to Swift, if present
        #if canImport(SwiftSyntax603)
        if let moduleSelector = memberType.moduleSelector {
          guard isSwiftModuleSelector(moduleSelector) else { continue }
        }
        #endif // canImport(SwiftSyntax630)
        
        // Update the constraint if required
        if let typeConstraint = TypeConstraint(from: memberType.name) {
          strictest.formIntersection(typeConstraint)
        }
        
      } else if let identifierType = constraint.type.as(IdentifierTypeSyntax.self) {
        
        // Make sure the module selector refers to Swift
        #if canImport(SwiftSyntax603)
        if let moduleSelector = identifierType.moduleSelector {
          guard isSwiftModuleSelector(moduleSelector) else { continue }
        }
        #endif // canImport(SwiftSyntax630)
        
        if let typeConstraint = TypeConstraint(from: identifierType.name) {
          strictest.formIntersection(typeConstraint)
        }
        
      } else if constraint.type.is(ClassRestrictionTypeSyntax.self) {
        
        // Handle deprecated class keyword
        strictest.formIntersection(.class)
        
      }
    }
    
    return strictest
  }
  
}
