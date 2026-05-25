import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
  static let moduleName = "TypeUtils"
  
  let providingMacros: [any Macro.Type] = [
    AddCaseKinds.self,
  ]
}
