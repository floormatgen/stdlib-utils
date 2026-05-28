import SwiftSyntax
import _MacroUtils

extension Reasync {
  
  struct Options {
    
    /// A custom name for the async function, or `nil` if one wasn't specified
    private(set) var name: String?
    
    /// Whether the decleration used the ``GlobalReasync`` macro
    ///
    /// This is needed to declare global functions `reasync`, as declaring arbritrary names
    /// is not allowed (see [Swift Forums](https://forums.swift.org/t/update-restrictions-on-arbitrary-names-at-global-scope-in-se-0389-and-se-0397/66289))
    private(set) var isGlobal: Bool
    
    /// Get options from the attribute decl
    ///
    /// This `init` must only be called using the ``Reasync`` attribute
    init(from attributeSyntax: AttributeSyntax) throws {
      
      // Set everything to defaults first
      self = .default
      
      // Check if the global version was used
      let checker = GlobalMacroChecker(macroName: globalName)
      self.isGlobal = checker.checkGlobalMacroUsed(in: attributeSyntax)
      
      // Check if there are any provided options, otherwise fallback to defaults
      guard
        let arguments = attributeSyntax.arguments,
        case .argumentList(let argumentList) = arguments
      else {
        return
      }
      
      // Check provided arguments
      for argument in argumentList {
        switch argument.label?.text {
        case "named":
          self.name = try CommonOptions.named(from: argument)
        default:
          preconditionFailure("Unknown option: \(argument.label?.text ?? "<unknown>")")
        }
      }
      
    }
    
    private init(name: String?, isGlobal: Bool) {
      self.name     = name
      self.isGlobal = isGlobal
    }
    
    static var `default`: Self {
      .init(
        name: nil,
        isGlobal: false
      )
    }
    
  }
  
}
