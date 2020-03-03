import MockoloFramework


let moduleOverride = """
/// \(String.mockAnnotation)(module: name = Foo)
protocol TaskRouting: BaseRouting {
    var bar: String { get }
    func baz() -> Double
}

"""

let moduleOverrideMock = """

class TaskRoutingMock: Foo.TaskRouting {
    
    private var _doneInit = false
    
    init() { _doneInit = true }
    init(bar: String = "") {
        self.bar = bar
        _doneInit = true
    }
    var barSetCallCount = 0
    var bar: String = "" { didSet { barSetCallCount += 1 } }
    var bazCallCount = 0
    var bazHandler: (() -> (Double))?
    func baz() -> Double {
        bazCallCount += 1
        if let bazHandler = bazHandler {
            return bazHandler()
        }
        return 0.0
    }
}
"""
