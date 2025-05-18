@attached(member, names: named(_source))
macro Fixture(
    imports: [String]? = nil,
    testableImports: [String]? = nil,
    includesConcurrencyHelpers: Bool = false
) = #externalMacro(module: "MockoloTestSupportMacros", type: "Fixture")
