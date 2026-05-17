/// A version of ``AddConcurrent()`` that accepts a custom name
///
/// This macro exists due to the fact that declaring arbritrary names at the global scope
/// is not supported.
///
/// For most functions, use ``AddConcurrent()`` instead.
/// Use this name when you want to override the default name.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
@attached(peer, names: arbitrary)
public macro CustomAddConcurrent(named: StaticString? = nil) = #externalMacro(
  module: "ConcurrencyUtilsMacros",
  type: "AddConcurrent"
)

/// Adds a concurrent alternative for a function
///
/// This is useful to move expensive work into the background.
/// This macro adds the `@concurrent` attribute to the generated function if it is supported.
///
/// ```swift
/// // Source
/// func expensiveWork() {
///   veryExpensive()
/// }
///
/// // Result
/// func expensiveWork() {
///   veryExpensive()
/// }
///
/// @concurrent
/// func expensiveWorkConcurrently() async {
///   expensiveWork()
/// }
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
@attached(peer, names: suffixed(Concurrently))
public macro AddConcurrent() = #externalMacro(
  module: "ConcurrencyUtilsMacros",
  type: "AddConcurrent"
)
