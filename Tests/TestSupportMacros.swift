@freestanding(expression)
macro Fixture(_ code: () -> () -> ()) -> FixtureContent = #externalMacro(module: "MockoloTestSupportMacros", type: "FixtureExpression")

struct FixtureContent {
    var source: String
    var expected: String
}
