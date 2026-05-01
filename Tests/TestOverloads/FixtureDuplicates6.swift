@Fixture enum overloadReturningBracketType {
    /// @mockable
    protocol P {
        func foo() -> [String]
        func foo() -> [[String]]
    }

    @Fixture enum expected {
        class PMock: P {
            init() { }


            private(set) var fooCallCount = 0
            var fooHandler: (() -> [String])?
            func foo() -> [String] {
                fooCallCount += 1
                if let fooHandler = fooHandler {
                    return fooHandler()
                }
                return [String]()
            }

            private(set) var fooArrayArrayStringCallCount = 0
            var fooArrayArrayStringHandler: (() -> [[String]])?
            func foo() -> [[String]] {
                fooArrayArrayStringCallCount += 1
                if let fooArrayArrayStringHandler = fooArrayArrayStringHandler {
                    return fooArrayArrayStringHandler()
                }
                return [[String]]()
            }
        }
    }
}
