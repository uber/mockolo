@attached(
    peer,
    names: suffixed(_rawSyntax)
)
macro Fixture() = #externalMacro(module: "MockoloTestSupportMacros", type: "Fixture")
