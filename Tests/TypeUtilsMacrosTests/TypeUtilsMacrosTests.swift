import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import TypeUtilsMacros

final class AddCaseKindsTests: XCTestCase {
  
  let testMacros: [String : any Macro.Type] = [
    "AddCaseKinds": AddCaseKinds.self
  ]
  
  func test_basicEnum() {
    assertMacroExpansion(
      """
      @AddCaseKinds
      enum Foo {
          case first
          case second
          case third
      }
      """,
      expandedSource: """
      enum Foo {
          case first
          case second
          case third
      
          enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
              case first
              case second
              case third
          }
      
          var kind: Kind {
              switch self {
              case .first:
                  return .first
              case .second:
                  return .second
              case .third:
                  return .third
              }
          }
      }
      """,
      macros: testMacros
    )
  }
  
  func test_emptyEnum() {
    assertMacroExpansion(
      """
      @AddCaseKinds
      enum Foo {
      }
      """,
      expandedSource: """
      enum Foo {

          enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
          }
      
          var kind: Kind {
              switch self {
              }
          }
      }
      """,
      macros: testMacros
    )
  }
  
  func test_associatedValues() {
    assertMacroExpansion(
      """
      @AddCaseKinds
      enum Foo {
          case first
          case second(Int)
          case third(Int, String)
      }
      """,
      expandedSource: """
      enum Foo {
          case first
          case second(Int)
          case third(Int, String)
      
          enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
              case first
              case second
              case third
          }
      
          var kind: Kind {
              switch self {
              case .first:
                  return .first
              case .second:
                  return .second
              case .third:
                  return .third
              }
          }
      }
      """,
      macros: testMacros
    )
  }
  
  func test_enumShorthand() {
    assertMacroExpansion(
      """
      @AddCaseKinds
      enum Foo {
          case first, second(Int)
          case third(Int, String)
      }
      """,
      expandedSource: """
      enum Foo {
          case first, second(Int)
          case third(Int, String)
      
          enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
              case first
              case second
              case third
          }
      
          var kind: Kind {
              switch self {
              case .first:
                  return .first
              case .second:
                  return .second
              case .third:
                  return .third
              }
          }
      }
      """,
      macros: testMacros
    )
  }
  
  func test_publicEnum() {
    assertMacroExpansion(
      """
      @AddCaseKinds
      public enum Foo {
          case first, second(Int)
          case third(Int, String)
      }
      """,
      expandedSource: """
      public enum Foo {
          case first, second(Int)
          case third(Int, String)
      
          public enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
              case first
              case second
              case third
          }
      
          public var kind: Kind {
              switch self {
              case .first:
                  return .first
              case .second:
                  return .second
              case .third:
                  return .third
              }
          }
      }
      """,
      macros: testMacros
    )
  }
  
  func test_privateNotAppliedToKind() {
    assertMacroExpansion(
      """
      @AddCaseKinds
      private enum Foo {
          case foo, bar, baz
      }
      """,
      expandedSource: """
      private enum Foo {
          case foo, bar, baz
      
          enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
              case foo
              case bar
              case baz
          }
      
          var kind: Kind {
              switch self {
              case .foo:
                  return .foo
              case .bar:
                  return .bar
              case .baz:
                  return .baz
              }
          }
      }
      """,
      macros: testMacros
    )
  }
  
}
