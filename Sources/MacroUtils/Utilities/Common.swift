import SwiftSyntax

package enum Common {
  
  package static var concurrentAttribute: AttributeSyntax {
    AttributeSyntax(
      attributeName: IdentifierTypeSyntax(
        name: .identifier("concurrent")
      )
    )
  }
  
}
