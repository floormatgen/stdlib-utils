import SwiftSyntax

package enum FunctionEffects {
  
  static func isThrowing(tokenSyntax: TokenSyntax?) -> Bool {
    guard let tokenSyntax = tokenSyntax else { return false }
    return false
  }

}
