import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import TypeUtilsMacros

final class AddCaseKindsTests: XCTestCase {
  
  let testMacros: [String : any Macro.Type] = [
    "AddCaseKind": AddCaseKind.self
  ]
  
  func test_basicEnum() {
    assertMacroExpansion(
      """
      @AddCaseKind
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
      
      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
  func test_emptyEnum() {
    assertMacroExpansion(
      """
      @AddCaseKind
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

      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
  func test_associatedValues() {
    assertMacroExpansion(
      """
      @AddCaseKind
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
      
      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
  func test_enumShorthand() {
    assertMacroExpansion(
      """
      @AddCaseKind
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

      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
  func test_publicEnum() {
    assertMacroExpansion(
      """
      @AddCaseKind
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
      
      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
  func test_privateNotAppliedToKind() {
    assertMacroExpansion(
      """
      @AddCaseKind
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
      
      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
  func test_modifiersCopiedFromParent() {
    assertMacroExpansion(
      """
      @AddCaseKind
      nonisolated package enum Foo {
          case first, second(Int)
          case third(Int, String)
      }
      """,
      expandedSource: """
      nonisolated package enum Foo {
          case first, second(Int)
          case third(Int, String)
      
          nonisolated package enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
              case first
              case second
              case third
          }
      
          package var kind: Kind {
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
      
      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
  func test_attributesCopiedFromParent() {
    assertMacroExpansion(
      """
      @nonexhaustive
      @AddCaseKind
      internal enum Foo {
          case first, second(Int)
          case third(Int, String)
      }
      """,
      expandedSource: """
      @nonexhaustive
      internal enum Foo {
          case first, second(Int)
          case third(Int, String)
      
          @nonexhaustive
          internal enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
              case first
              case second
              case third
          }
      
          internal var kind: Kind {
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
      
      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
  func test_indirectRemovedFromKind() {
    assertMacroExpansion(
      """
      @AddCaseKind
      fileprivate indirect enum Foo {
          case first, second(Int)
          case third(Int, String)
      }
      """,
      expandedSource: """
      fileprivate indirect enum Foo {
          case first, second(Int)
          case third(Int, String)
      
          fileprivate enum Kind: Swift.Sendable, Swift.Equatable, Swift.Hashable {
              case first
              case second
              case third
          }
      
          fileprivate var kind: Kind {
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
      
      extension Foo: TypeUtils.CaseKindProvider {
      }
      """,
      macros: testMacros
    )
  }
  
}
