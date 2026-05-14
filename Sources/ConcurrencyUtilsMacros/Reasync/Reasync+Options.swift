import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftParser

extension Reasync {
  
  struct Options {
    /// A custom name for the async function, or `nil` if one wasn't specified
    var name: String?
    
    /// Get options from the attribute decl
    ///
    /// This `init` must only be called using the ``Reasync`` attribute
    init(from attributeSyntax: AttributeSyntax) throws {
      
      // Set everything to defaults first
      self = .default
      
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
          self.name = try Self.name(from: argument)
        default:
          preconditionFailure("Unknown option: \(argument.label?.text ?? "")")
        }
      }
      
    }
    
    private init(name: String?) {
      self.name = name
    }
    
    static var `default`: Self {
      .init(
        name: nil
      )
    }
    
  }
  
}

// MARK: - Argument Handling

extension Reasync.Options {
  
  static func name(from labeledExpr: LabeledExprSyntax) throws -> String {
    precondition(labeledExpr.label?.text == "named")
    
    // Make sure the name is provided as a string literal
    guard
      let nameLiteral = labeledExpr.expression.as(StringLiteralExprSyntax.self),
      let resolvedName = nameLiteral.representedLiteralValue
    else {
      throw Error.nameNotValidStringLiteral(node: labeledExpr)
    }
    
    return resolvedName
  }
  
}

// MARK: - Errors

extension Reasync.Options {
  
  enum Error {
    
    static func nameNotValidStringLiteral(node: some SyntaxProtocol) -> DiagnosticsError {
      DiagnosticsError(diagnostics: [
        Diagnostic(
          node: node,
          message: MacroExpansionErrorMessage("Custom name must be a valid string literal")
        )
      ])
    }
    
  }
  
}
