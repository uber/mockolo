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

            private(set) var fooArrayArrayCallCount = 0
            var fooArrayArrayHandler: (() -> [[String]])?
            func foo() -> [[String]] {
                fooArrayArrayCallCount += 1
                if let fooArrayArrayHandler = fooArrayArrayHandler {
                    return fooArrayArrayHandler()
                }
                return [[String]]()
            }
        }
    }
}
