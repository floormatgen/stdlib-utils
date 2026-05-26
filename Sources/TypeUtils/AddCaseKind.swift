/// Adds a kind accessor to the `enum`
///
/// This property can be used to check if enums have the same case,
/// without considering their associated values.
///
/// This is achieved by generating a nested `Kind` `enum` which duplicates
/// all the cases, but strips the associated values. To get the  `kind` of the
/// current `enum`, use the `kind` property:
///
/// ```swift
/// @AddCaseKind
/// enum Bar {
///   case .foo
///   case .bar(Int)
///   case .baz(Int, Int)
/// }
///
/// let bar = Bar.bar
/// _ = bar.kind // Bar.Kind.bar
/// ```
///
/// These kinds can also be compared:
///
/// ```swift
/// @AddCaseKind
/// enum Foo {
///   case .first
///   case .second(Int)
///   case .third(Int, String)
/// }
///
/// let foo1 = Foo.second(42)
/// let foo2 = Foo.second(0)
/// assert(foo1.kind == foo2.kind)
/// ```
///
/// ## Modifiers and Attributes
/// The `Kind` enum conforms to `Sendable`, `Equatable` and `Hashable`
/// by default, in order to allow easy comparison between the different kinds
/// of enum cases.
///
/// The generated nested `Kind` enum generally inherits the modifiers and attributes
/// of the hosting enum, with the following exceptions:
/// - If the `private` access modifier is used, the access modifier is not inherited
///   for both the `Kind` enum and `kind` property.
/// - If the `indirect` keyword is used on the hosting enum,
///   it is removed on the `Kind` enum.
///
@attached(member, names: named(Kind), named(kind))
@attached(extension, conformances: TypeUtils.CaseKindProvider)
public macro AddCaseKind() = #externalMacro(
  module: "TypeUtilsMacros",
  type: "AddCaseKind"
)

/// A type that provides case kinds
///
/// Don't conform to this protocol by yourself,
/// use the ``AddCaseKind()`` macro instead.
public protocol CaseKindProvider {
  
  /// The nested type describing the cases of the `enum`
  associatedtype Kind: Sendable, Equatable, Hashable
  
  /// The kind of the current `enum`
  var kind: Kind { get }
  
}
