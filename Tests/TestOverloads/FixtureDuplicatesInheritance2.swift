import MockoloFramework

let overload9 = """
/// \(String.mockAnnotation)
protocol Foo {
func update(arg: Int)
}

/// \(String.mockAnnotation)
protocol Bar: Foo {
func update(arg: Int)
}
"""

let overloadMock9 =
"""


class FooMock: Foo {
    init() { }


    private(set) var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }
}

class BarMock: Bar {
    init() { }


    private(set) var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }
}
"""
