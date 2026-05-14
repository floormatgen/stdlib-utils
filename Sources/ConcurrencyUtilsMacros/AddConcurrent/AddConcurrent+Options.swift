import SwiftSyntax

extension AddConcurrent {
  
  struct Options {
    private(set) var name: String?
    private(set) var isGlobal: Bool
    
    init(from attributeSyntax: AttributeSyntax) throws {
      self = .default
      
      let checker = GlobalMacroChecker(macroName: globalName)
      self.isGlobal = checker.checkGlobalMacroUsed(in: attributeSyntax)
      
      guard
        let arguments = attributeSyntax.arguments,
        case .argumentList(let argumentList) = arguments
      else {
        return
      }
      
      for argument in argumentList {
        switch argument.label?.text {
        case CommonOptions.named:
          self.name = try CommonOptions.named(from: argument)
        default:
          preconditionFailure("Unknown option: \(argument.label?.text ?? "<unknown>")")
        }
      }
    }
    
    private init(name: String?, isGlobal: Bool) {
      self.name = name
      self.isGlobal = isGlobal
    }
    
    static var `default`: Options {
      .init(
        name: nil,
        isGlobal: false
      )
    }
    
  }
  
}
