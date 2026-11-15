import MockoloFramework

@Fixture enum simpleVars {
    /// @mockable
    protocol SimpleVar {
        var name: Int { get set }
    }

    @Fixture enum expected {
        class SimpleVarMock: SimpleVar {
            init() { }
            init(name: Int = 0) {
                self.name = name
            }
            
            private(set) var nameSetCallCount = 0
            var name: Int = 0 { didSet { nameSetCallCount += 1 } }
        }
    }

    @Fixture enum allowsCallCountExpected {
        class SimpleVarMock: SimpleVar {
            init() { }
            init(name: Int = 0) {
                self.name = name
            }

            var nameSetCallCount = 0
            var name: Int = 0 { didSet { nameSetCallCount += 1 } }
        }
    }

    @Fixture enum addsFinalExpected {
        final class SimpleVarMock: SimpleVar {
            init() { }
            init(name: Int = 0) {
                self.name = name
            }

            private(set) var nameSetCallCount = 0
            var name: Int = 0 { didSet { nameSetCallCount += 1 } }
        }
    }
}
