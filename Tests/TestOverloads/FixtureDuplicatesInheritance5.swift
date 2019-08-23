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
    
    private var _doneInit = false
    
    init() {
        
        _doneInit = true
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateCallCount += 1
        
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }
    
    var updateArgCallCount = 0
    var updateArgHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArgCallCount += 1
        
        if let updateArgHandler = updateArgHandler {
            updateArgHandler(arg)
        }
        
    }
    
    var displayCallCount = 0
    var displayHandler: ((String) -> ())?
    func display(param: String)  {
        displayCallCount += 1
        
        if let displayHandler = displayHandler {
            displayHandler(param)
        }
        
    }
}

class BarMock: Bar {
    
    private var _doneInit = false
    
    init() {
        
        _doneInit = true
    }
    
    var updateArgCallCount = 0
    var updateArgHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateArgCallCount += 1
        
        if let updateArgHandler = updateArgHandler {
            updateArgHandler(arg)
        }
        
    }
    
    var displayParamCallCount = 0
    var displayParamHandler: ((String) -> ())?
    func display(param: String)  {
        displayParamCallCount += 1
        
        if let displayParamHandler = displayParamHandler {
            displayParamHandler(param)
        }
        
    }
    
    var updateCallCount = 0
    var updateHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateCallCount += 1
        
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }
    
    var displayCallCount = 0
    var displayHandler: ((Double) -> ())?
    func display(param: Double)  {
        displayCallCount += 1
        
        if let displayHandler = displayHandler {
            displayHandler(param)
        }
        
    }
}

class BazMock: Baz {
    
    private var _doneInit = false
    
    init() {
        
        _doneInit = true
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateCallCount += 1
        
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }
    
    var updateArgCallCount = 0
    var updateArgHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArgCallCount += 1
        
        if let updateArgHandler = updateArgHandler {
            updateArgHandler(arg)
        }
        
    }
    
    var displayParamStringCallCount = 0
    var displayParamStringHandler: ((String) -> ())?
    func display(param: String)  {
        displayParamStringCallCount += 1
        
        if let displayParamStringHandler = displayParamStringHandler {
            displayParamStringHandler(param)
        }
        
    }
    
    var displayCallCount = 0
    var displayHandler: ((Double) -> ())?
    func display(param: Double)  {
        displayCallCount += 1
        
        if let displayHandler = displayHandler {
            displayHandler(param)
        }
        
    }
    
    var displayParamCallCount = 0
    var displayParamHandler: ((Int) -> ())?
    func display(param: Int)  {
        displayParamCallCount += 1
        
        if let displayParamHandler = displayParamHandler {
            displayParamHandler(param)
        }
        
    }
    
    var showCallCount = 0
    var showHandler: ((String) -> ())?
    func show(param: String)  {
        showCallCount += 1
        
        if let showHandler = showHandler {
            showHandler(param)
        }
        
    }
}
"""
