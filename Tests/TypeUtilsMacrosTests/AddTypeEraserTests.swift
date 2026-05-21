import XCTest
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import TypeUtilsMacros

final class AddTypeEraserTests: XCTestCase {
  
  let testMacros: [String : any Macro.Type] = [
    "AddTypeEraser": AddTypeEraser.self
  ]
  
  func test_emptyProtocol() {
    assertMacroExpansion(
      """
      @AddTypeEraser
      protocol Foo {
      }
      """,
      expandedSource: """
      protocol Foo {
      }
      
      struct AnyFoo: Foo {
          var base: any Foo
          init<T: Foo>(erasing base: consuming T) {
              self.base = base
          }
          init<T: Foo>(_ base: consuming T) {
              self.base = base
          }
      }
      """,
      macros: testMacros
    )
  }
  
  func test_emptyPublicProtocol() {
    assertMacroExpansion(
      """
      @AddTypeEraser
      public protocol Foo {
      }
      """,
      expandedSource: """
      public protocol Foo {
      }
      
      public struct AnyFoo: Foo {
          public var base: any Foo
          public init<T: Foo>(erasing base: consuming T) {
              self.base = base
          }
          public init<T: Foo>(_ base: consuming T) {
              self.base = base
          }
      }
      """,
      macros: testMacros
    )
  }
  
  func test_packageClassBoundProtocol() {
    assertMacroExpansion(
      """
      @AddTypeEraser
      package protocol Foo: AnyObject {
      }
      """,
      expandedSource: """
      package protocol Foo: AnyObject {
      }
      
      package final class AnyFoo: Foo {
          package let base: any Foo
          package init<T: Foo>(erasing base: consuming T) {
              self.base = base
          }
          package init<T: Foo>(_ base: consuming T) {
              self.base = base
          }
      }
      """,
      macros: testMacros
    )
  }
  
}
