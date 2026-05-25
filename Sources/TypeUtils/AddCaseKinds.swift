@attached(member, names: named(Kind), named(kind))
public macro AddCaseKinds() = #externalMacro(
  module: "TypeUtilsMacros",
  type: "AddCaseKinds"
)

@AddCaseKinds
enum Foo {
  case a, b, c
}
