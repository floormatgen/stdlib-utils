
// MARK: - Macro

/// Creates an async overload of a provided function
///
/// This is useful for "with-style" methods that take a body closure.
/// It prefixes all calls to function parameters with `await` 
/// and makes function arguments `async`.
///
/// ```swift
/// // Source
/// @Reasync
/// func withFoo<E: Error, R: ~Copyable>(
///   operation: (Foo) throws(E) -> R
/// ) throws(E) -> R {
///   return try operation(foo)
/// }
/// 
/// // Result
/// func withFoo<E: Error, R: ~Copyable>(
///   operation: (Foo) throws(E) -> R
/// ) throws(E) -> R {
///   return try operation(foo)
/// }
/// 
/// nonisolated(nonsending)
/// func withFoo<E: Error, R: ~Copyable>(
///   operation: (Foo) async throws(E) -> R
/// ) async throws(E) -> R {
///   return try await operation(foo)
/// }
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
@attached(peer, names: arbitrary)
public macro Reasync(named: StaticString? = nil) = #externalMacro(
  module: "ConcurrencyUtilsMacros",
  type: "Reasync"
)

/// A version of ``Reasync`` suitable for use at the global scope
///
/// This version exists because arbritrary names are not allowed at the global scope,
/// which is needed to support custom names for ``Reasync``. As such, this version
/// doesn't allow custom names, with only overloading supported.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
@attached(peer, names: overloaded)
public macro GlobalReasync() = #externalMacro(
  module: "ConcurrencyUtilsMacros",
  type: "Reasync"
)
