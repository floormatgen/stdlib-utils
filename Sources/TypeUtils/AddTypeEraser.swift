@attached(peer, names: prefixed(Any))
public macro AddTypeEraser() = #externalMacro(
  module: "TypeUtilsMacros",
  type: "AddTypeEraser"
)
