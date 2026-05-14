import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import ConcurrencyUtilsMacros

final class ReasyncTests: XCTestCase {
  
  static let testMacros: [String: any Macro.Type] = [
    "Reasync":        Reasync.self,
    "GlobalReasync":  Reasync.self,
  ]
  
#if compiler(>=6.2)
  
  func test_macroRemovedOnExpansion() {
    assertMacroExpansion(
      """
      @Reasync
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
  
  func test_addsAsyncToParameters() {
    assertMacroExpansion(
      """
      @Reasync
      func foo(operation: () -> Void) -> Void {
        return operation()
      }
      """,
      expandedSource: """
      func foo(operation: () -> Void) -> Void {
        return operation()
      }
      
      nonisolated(nonsending)
      func foo(operation: nonisolated(nonsending) () async -> Void) async -> Void {
        return await operation()
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_doesNotAddAsyncToOtherFunctions() {
    assertMacroExpansion(
      """
      enum Foo {
        static func operation() {
        }
      }

      @Reasync
      func foo(operation: () -> Void) -> Void {
        Foo.operation()
        return operation()
      }
      """,
      expandedSource: """
      enum Foo {
        static func operation() {
        }
      }
      func foo(operation: () -> Void) -> Void {
        Foo.operation()
        return operation()
      }
      
      nonisolated(nonsending)
      func foo(operation: nonisolated(nonsending) () async -> Void) async -> Void {
        Foo.operation()
        return await operation()
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_doesNotAddAsyncToInstanceFunctions() {
    assertMacroExpansion(
      """
      class Foo {
          
        func body() {
        }
      
        @Reasync
        func withResource(
          _ body: () -> Void
        ) -> Void {
          self.body()
          body()
        }
      
      }
      """,
      expandedSource: """
      class Foo {
          
        func body() {
        }
        func withResource(
          _ body: () -> Void
        ) -> Void {
          self.body()
          body()
        }
      
        nonisolated(nonsending)
          func withResource(
            _ body: nonisolated(nonsending) () async -> Void
          ) async -> Void {
            self.body()
            await body()
          }
      
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_cutomNameUsed() {
    assertMacroExpansion(
      """
      @Reasync(named: "fooAsync")
      func foo(_ operation: () -> Void) {
      }
      """,
      expandedSource: """
      func foo(_ operation: () -> Void) {
      }
      
      nonisolated(nonsending)
      func fooAsync(_ operation: nonisolated(nonsending) () async -> Void) async {
      }
      """,
      macros: Self.testMacros
    )
  }
  
#endif // compiler(>=6.2)

}

final class GlobalReasyncTests: XCTestCase {
  
  static var testMacros: [String : any Macro.Type] {
    ReasyncTests.testMacros
  }
  
#if compiler(>=6.2)
  
  func test_macroRemovedOnExpansion() {
    assertMacroExpansion(
      """
      @GlobalReasync
      func foo(_ operation: () -> Void) {
      }
      """,
      expandedSource: """
      func foo(_ operation: () -> Void) {
      }
      
      nonisolated(nonsending)
      func foo(_ operation: nonisolated(nonsending) () async -> Void) async {
      }
      """,
      macros: Self.testMacros
    )
  }
  
#endif // compiler(>=6.2)
  
}
