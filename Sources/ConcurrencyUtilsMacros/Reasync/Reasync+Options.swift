import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import SwiftParser

extension Reasync {
  
  struct Options {
    
    /// A custom name for the async function, or `nil` if one wasn't specified
    var name: String?
    
    /// Whether the decleration used the ``GlobalReasync`` macro
    ///
    /// This is needed to declare global functions `reasync`, as declaring arbritrary names
    /// is not allowed (see [Swift Forums](https://forums.swift.org/t/update-restrictions-on-arbitrary-names-at-global-scope-in-se-0389-and-se-0397/66289))
    var isGlobal: Bool
    
    /// Get options from the attribute decl
    ///
    /// This `init` must only be called using the ``Reasync`` attribute
    init(from attributeSyntax: AttributeSyntax) throws {
      
      // Set everything to defaults first
      self = .default
      
      // Check if the global version was used
      let checker = GlobalMacroChecker()
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
          self.name = try Self.name(from: argument)
        default:
          preconditionFailure("Unknown option: \(argument.label?.text ?? "")")
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

// MARK: - SyntaxVistors

private final class GlobalMacroChecker: SyntaxVisitor {
  var containsGlobalMacro: Bool = false
  
  private static var gloablMacroName: String { Reasync.globalName }
  
  init() {
    super.init(viewMode: .sourceAccurate)
  }
  
  func checkGlobalMacroUsed(in node: AttributeSyntax) -> Bool {
    containsGlobalMacro = false
    walk(node.attributeName)
    return containsGlobalMacro
  }
  
  override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
    if node.name.text == Self.gloablMacroName {
      containsGlobalMacro = true
      return .skipChildren
    }
    return .visitChildren
  }
  
  override func visit(_ node: MemberTypeSyntax) -> SyntaxVisitorContinueKind {
    if node.name.text == Self.gloablMacroName {
      containsGlobalMacro = true
      return .skipChildren
    }
    return .visitChildren
  }
  
}
