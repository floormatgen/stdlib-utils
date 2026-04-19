
// MARK: - Macro

/// Creates an async mirror of a provided function
/// 
/// This is useful for "with-style" methods that take a body closure.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
@attached(peer, names: overloaded)
public macro AsyncAlternative() = #externalMacro(module: "ConcurrencyUtilsMacros", type: "AsyncAlternative")
