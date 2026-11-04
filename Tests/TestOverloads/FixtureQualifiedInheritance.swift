let sameNameQualifiedInheritance = """
import OtherModule

/// @mockable
protocol P: OtherModule.P {
    func child()
}
"""

let sameNameQualifiedInheritanceMock = """
import OtherModule


class PMock: P {
    init() { }


    private(set) var childCallCount = 0
    var childHandler: (() -> ())?
    func child() {
        childCallCount += 1
        if let childHandler = childHandler {
            childHandler()
        }
    }
}
"""

@Fixture enum moduleQualifiedInheritance {
    protocol Parent {
        func foo()
    }

    /// @mockable
    protocol Child: moduleQualifiedInheritance.Parent {
        func bar()
    }

    @Fixture enum expected {
        class ChildMock: Child {
            init() { }


            private(set) var fooCallCount = 0
            var fooHandler: (() -> ())?
            func foo() {
                fooCallCount += 1
                if let fooHandler = fooHandler {
                    fooHandler()
                }
            }

            private(set) var barCallCount = 0
            var barHandler: (() -> ())?
            func bar() {
                barCallCount += 1
                if let barHandler = barHandler {
                    barHandler()
                }
            }
        }
    }
}
