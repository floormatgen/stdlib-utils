import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import ConcurrencyUtilsMacros

final class AddConcurrentTests: XCTestCase {
  
  static let testMacros: [String : any Macro.Type] = [
    "AddConcurrent": AddConcurrent.self
  ]
  
#if compiler(>=6.2)
  
  func test_addsConcurrent() {
    assertMacroExpansion(
      """
      @AddConcurrent
      func foo() {
      }
      """,
      expandedSource: """
      func foo() {
      }
      
      @concurrent
      func fooConcurrently() async {
          foo()
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_withLabeledArguments() {
    assertMacroExpansion(
      """
      @AddConcurrent
      func foo(bar: String, baz: Bool) {
      }
      """,
      expandedSource: """
      func foo(bar: String, baz: Bool) {
      }
      
      @concurrent
      func fooConcurrently(bar: String, baz: Bool) async {
          foo(bar: bar, baz: baz)
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_withUnlabeledArgumentsAndThrows() {
    assertMacroExpansion(
      """
      @AddConcurrent
      func foo(_ bar: String, _ baz: Bool) throws {
      }
      """,
      expandedSource: """
      func foo(_ bar: String, _ baz: Bool) throws {
      }
      
      @concurrent
      func fooConcurrently(_ bar: String, _ baz: Bool) async throws {
          try foo(bar, baz)
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_withIgnoredArguments() {
    assertMacroExpansion(
      """
      @AddConcurrent
      func foo(_: String, _: Bool, _: Int) {
      }
      """,
      expandedSource: """
      func foo(_: String, _: Bool, _: Int) {
      }
      
      @concurrent
      func fooConcurrently(_ __macro_local_1_fMu_: String, _ __macro_local_1_fMu0_: Bool, _ __macro_local_1_fMu1_: Int) async {
          foo(__macro_local_1_fMu_, __macro_local_1_fMu0_, __macro_local_1_fMu1_)
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_alreadyAsync() {
    assertMacroExpansion(
      """
      @AddConcurrent
      func foo() async {
      }
      """,
      expandedSource: """
      func foo() async {
      }
      
      @concurrent
      func fooConcurrently() async {
          await foo()
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_respectsRawIdentifiers() {
    assertMacroExpansion(
      """
      @AddConcurrent
      func `default`() {
      }
      """,
      expandedSource: """
      func `default`() {
      }
      
      @concurrent
      func `defaultConcurrently`() async {
          `default`()
      }
      """,
      macros: Self.testMacros
    )
  }
  
  func test_removeNonisolatedNonsending() {
    assertMacroExpansion(
      """
      @AddConcurrent
      nonisolated(nonsending) func foo() async {
      }
      """,
      expandedSource: """
      nonisolated(nonsending) func foo() async {
      }
      
      @concurrent func fooConcurrently() async {
          await foo()
      }
      """,
      macros: Self.testMacros
    )
  }
  
#endif // compiler(>=6.2)
  
}
