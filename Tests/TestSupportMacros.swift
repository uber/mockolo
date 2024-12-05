@attached(
    peer,
    names: suffixed(_Fixture)
)
macro Fixture() = #externalMacro(module: "MockoloTestSupportMacros", type: "Fixture")
