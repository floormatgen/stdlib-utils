
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
@attached(peer, names: overloaded)
public macro Reasync(named: StaticString? = nil)
  = #externalMacro(module: "ConcurrencyUtilsMacros", type: "Reasync")
