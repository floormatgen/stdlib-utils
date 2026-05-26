import SwiftSyntax

public enum Common {
  
  public enum Attributes {
    
    public static var concurrent: AttributeSyntax {
      AttributeSyntax(
        attributeName: IdentifierTypeSyntax(
          name: .identifier("concurrent")
        )
      )
    }
    
  }
  
  public enum Protocols {
    private static let swiftModuleName = "Swift"
    private static let swiftModuleBaseType = IdentifierTypeSyntax(name: .identifier(swiftModuleName))
    
    public static var Sendable: TypeSyntax {
      TypeSyntax(
        MemberTypeSyntax(
          baseType: swiftModuleBaseType,
          name: .identifier("Sendable")
        )
      )
    }
    
    public static var Equatable: TypeSyntax {
      TypeSyntax(
        MemberTypeSyntax(
          baseType: swiftModuleBaseType,
          name: .identifier("Equatable")
        )
      )
    }
    
    public static var Hashable: TypeSyntax {
      TypeSyntax(
        MemberTypeSyntax(
          baseType: swiftModuleBaseType,
          name: .identifier("Hashable")
        )
      )
    }
    
  }
  
}
