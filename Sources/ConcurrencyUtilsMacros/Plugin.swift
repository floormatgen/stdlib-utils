import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
  
  static let moduleName: String = "ConcurrencyUtilsMacros"
  static let hostingModuleName: String = "ConcurrencyUtils"
  
  let providingMacros: [any Macro.Type] = [
    Reasync.self,
    ConcurrentAlternative.self
  ]
}
