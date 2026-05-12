@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
@attached(member, names: suffixed(Concurrently))
public macro ConcurrentAlternative() = #externalMacro(module: "ConcurrencyUtilsMacros", type: "ConcurrentAlternative")
