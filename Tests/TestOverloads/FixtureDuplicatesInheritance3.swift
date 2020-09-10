import MockoloFramework

let overload10 = """
/// \(String.mockAnnotation)
protocol Foo {
func update(arg: Int)
}

/// \(String.mockAnnotation)
protocol Bar {
func update(arg: Int)
}

/// \(String.mockAnnotation)
protocol Baz: Foo, Bar {
}
"""

let overloadMock10 =
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

class BazMock: Baz {
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
