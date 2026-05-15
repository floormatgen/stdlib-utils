import SwiftSyntax

package extension DeclModifierListSyntax {
  
  mutating func removeNonisolatedNonsending() {
    self = filter { modifier in
      guard
        modifier.name.tokenKind == .keyword(.nonisolated),
        let detail = modifier.detail,
        detail.detail.tokenKind == .identifier("nonsending") || detail.detail.tokenKind == .keyword(.nonsending)
      else {
        return true
      }
      return false
    }
  }
  
}
