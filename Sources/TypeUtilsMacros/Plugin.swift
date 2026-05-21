import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
  
  static let moduleName = "TypeUtilsMacros"
  static let hostingModuleName = "TypeUtils"
  
  let providingMacros: [any Macro.Type] = [
    AddTypeEraser.self,
  ]
  
}
