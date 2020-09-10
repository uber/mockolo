import MockoloFramework

let overload11 = """
/// \(String.mockAnnotation)
protocol Foo {
func update(arg: Int)
func update(arg: Float)
func display(param: String)
}

/// \(String.mockAnnotation)
protocol Bar: Foo {
func update(arg: Float)
func display(param: Double)
}

/// \(String.mockAnnotation)
protocol Baz: Foo, Bar {
func display(param: Double)
func display(param: Int)
func show(param: String)
}
"""

let overloadMock11 =
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

    private(set) var updateArgCallCount = 0
    var updateArgHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            updateArgHandler(arg)
        }
        
    }

    private(set) var displayCallCount = 0
    var displayHandler: ((String) -> ())?
    func display(param: String)  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            displayHandler(param)
        }
        
    }
}

class BarMock: Bar {
    init() { }


    private(set) var updateArgCallCount = 0
    var updateArgHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            updateArgHandler(arg)
        }
        
    }

    private(set) var displayParamCallCount = 0
    var displayParamHandler: ((String) -> ())?
    func display(param: String)  {
        displayParamCallCount += 1
        if let displayParamHandler = displayParamHandler {
            displayParamHandler(param)
        }
        
    }

    private(set) var updateCallCount = 0
    var updateHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }

    private(set) var displayCallCount = 0
    var displayHandler: ((Double) -> ())?
    func display(param: Double)  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            displayHandler(param)
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

    private(set) var updateArgCallCount = 0
    var updateArgHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            updateArgHandler(arg)
        }
        
    }

    private(set) var displayParamStringCallCount = 0
    var displayParamStringHandler: ((String) -> ())?
    func display(param: String)  {
        displayParamStringCallCount += 1
        if let displayParamStringHandler = displayParamStringHandler {
            displayParamStringHandler(param)
        }
        
    }

    private(set) var displayCallCount = 0
    var displayHandler: ((Double) -> ())?
    func display(param: Double)  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            displayHandler(param)
        }
        
    }

    private(set) var displayParamCallCount = 0
    var displayParamHandler: ((Int) -> ())?
    func display(param: Int)  {
        displayParamCallCount += 1
        if let displayParamHandler = displayParamHandler {
            displayParamHandler(param)
        }
        
    }

    private(set) var showCallCount = 0
    var showHandler: ((String) -> ())?
    func show(param: String)  {
        showCallCount += 1
        if let showHandler = showHandler {
            showHandler(param)
        }
        
    }
}

"""
