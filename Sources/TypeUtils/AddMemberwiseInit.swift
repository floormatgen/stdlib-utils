@attached(member, names: named(init))
public macro AddMemberwiseInit() = #externalMacro(
  module: "TypeUtilsMacros",
  type: "AddMemberwiseInit"
)
