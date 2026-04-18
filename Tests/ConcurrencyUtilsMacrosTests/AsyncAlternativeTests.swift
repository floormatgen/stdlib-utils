import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import ConcurrencyUtilsMacros

final class AsyncAlternativeTests: XCTestCase {
  
  static let testMacros: [String: any Macro.Type] = [
    "AsyncAlternative": AsyncAlternative.self
  ]
  
#if compiler(>=6.2)
  
  func test_macroRemovedOnExpansion() {
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
  
  func test_addsAsyncToParameters() {
    assertMacroExpansion(
      """
      @AsyncAlternative
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

      @AsyncAlternative
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
      
        @AsyncAlternative
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
  
#endif // compiler(>=6.2)
  
}
