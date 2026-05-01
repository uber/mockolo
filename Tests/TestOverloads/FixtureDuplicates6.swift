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

            private(set) var fooStringArrayArrayCallCount = 0
            var fooStringArrayArrayHandler: (() -> [[String]])?
            func foo() -> [[String]] {
                fooStringArrayArrayCallCount += 1
                if let fooStringArrayArrayHandler = fooStringArrayArrayHandler {
                    return fooStringArrayArrayHandler()
                }
                return [[String]]()
            }
        }
    }
}
