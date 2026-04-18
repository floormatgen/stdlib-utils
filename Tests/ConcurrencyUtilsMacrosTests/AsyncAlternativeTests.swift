import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import ConcurrencyUtilsMacros

final class SwiftSyntaxMacrosTests: XCTestCase {
  
  static let testMacros: [String: any Macro.Type] = [
    "AsyncAlternative": AsyncAlternative.self
  ]
  
#if compiler(>=6.2)
  
  func testMacroRemovedOnExpansion() {
    assertMacroExpansion(
      """
      @AsyncAlternative
      func foo(operation: () -> Void) -> Void {
      }
      """,
      expandedSource: """
      func foo(operation: () -> Void) -> Void {
      }
      
      nonisolated(nonsending)
      func foo(operation: nonisolated(nonsending) () async -> Void) async -> Void {
      }
      """,
      macros: Self.testMacros
    )
  }
  
#endif // compiler(>=6.2)
  
}
