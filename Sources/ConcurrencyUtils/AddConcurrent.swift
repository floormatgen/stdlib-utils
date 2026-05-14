@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
@attached(peer, names: arbitrary)
public macro AddConcurrent(named: StaticString? = nil) = #externalMacro(
  module: "ConcurrencyUtilsMacros",
  type: "AddConcurrent"
)

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)
@attached(peer, names: suffixed(Concurrently))
public macro GlobalAddConcurrent() = #externalMacro(
  module: "ConcurrencyUtilsMacros",
  type: "AddConcurrent"
)
