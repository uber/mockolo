import MockoloFramework

@Fixture(
    imports: ["Foundation"]
)
enum testableImports {
    /// @mockable
    protocol SimpleVar {
        var name: Int { get set }
    }

    @Fixture(
        imports: ["Foundation"],
        testableImports: ["SomeImport1", "SomeImport2"]
    )
    enum expected {
        class SimpleVarMock: SimpleVar {
            init() { }
            init(name: Int = 0) {
                self.name = name
            }
            
            
            private(set) var nameSetCallCount = 0
            var name: Int = 0 { didSet { nameSetCallCount += 1 } }
        }
    }
}

@Fixture(
    imports: ["Foundation", "SomeImport1"]
)
enum testableImportsWithOverlap {
    /// @mockable
    protocol SimpleVar {
        var name: Int { get set }
    }

    @Fixture(
        imports: ["Foundation"],
        testableImports: ["SomeImport1"]
    )
    enum expected {
        class SimpleVarMock: SimpleVar {
            init() { }
            init(name: Int = 0) {
                self.name = name
            }

            private(set) var nameSetCallCount = 0
            var name: Int = 0 { didSet { nameSetCallCount += 1 } }
        }
    }
}
