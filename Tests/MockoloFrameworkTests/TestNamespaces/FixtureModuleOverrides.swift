import MockoloFramework


let moduleOverride = """
/// @mockable(module: prefix = Foo)
protocol TaskRouting: BaseRouting {
    var bar: String { get }
    func baz() -> Double
}

"""

let moduleOverrideMock = """

class TaskRoutingMock: Foo.TaskRouting {
    init() { }
    init(bar: String = "") {
        self.bar = bar
    }

    var bar: String = ""
    private(set) var bazCallCount = 0
    var bazHandler: (() -> Double)?
    func baz() -> Double {
        bazCallCount += 1
        if let bazHandler = bazHandler {
            return bazHandler()
        }
        return 0.0
    }
}
"""
