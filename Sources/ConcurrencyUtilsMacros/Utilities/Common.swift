import SwiftSyntax

package enum Common {
  
  static var concurrentAttribute: AttributeSyntax {
    AttributeSyntax(
      attributeName: IdentifierTypeSyntax(
        name: .identifier("concurrent")
      )
    )
  }
  
}
