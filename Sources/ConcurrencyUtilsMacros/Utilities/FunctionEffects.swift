import SwiftSyntax

extension FunctionEffectSpecifiersSyntax {
  
  func addingAsync() -> Self {
    var newSpecifiers = self
    newSpecifiers.asyncSpecifier = .keyword(.async)
    return newSpecifiers
  }
  
  mutating func addAsync() {
    self = addingAsync()
  }
  
}

extension Optional<FunctionEffectSpecifiersSyntax> {
  
  func addingAsync() -> Self {
    return .some((self ?? FunctionEffectSpecifiersSyntax()).addingAsync())
  }
  
  mutating func addAsync() {
    self = addingAsync()
  }
  
}
