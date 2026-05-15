package enum RawIdentifiers {
  
  package static func unwrapIdentifierIfNeeded(
    _ identifier: String
  ) -> (wrapped: String, isWrapped: Bool) {
    guard !identifier.isEmpty else { return (identifier, false) }
    
    if identifier.first == "`" && identifier.last == "`" {
      return (String(identifier.dropLast().dropFirst()), true)
    } else {
      return (identifier, false)
    }
  }
  
  package static func wrapIdentifier(
    _ identifier: String
  ) -> String {
    "`\(identifier)`"
  }
  
}
