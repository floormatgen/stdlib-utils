@attached(peer, names: overloaded)
public macro AsyncAlternative() = #externalMacro(module: "ConcurrencyUtilsMacros", type: "AsyncAlternative")


@AsyncAlternative @Sendable nonisolated
func foo(_ operation: () -> Void) -> Void {
  return operation()
}
