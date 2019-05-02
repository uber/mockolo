import MockoloFramework

let duplicateSigInheritance5 = """
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

let duplicateSigInheritanceMock5 = """
class FooMock: Foo {
    
    init() {
        
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        
    }
    var updateArgCallCount = 0
    var updateArgHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg)
        }
        
    }
    var displayCallCount = 0
    var displayHandler: ((String) -> ())?
    func display(param: String)  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            return displayHandler(param)
        }
        
    }
}

class BarMock: Bar {
    
    init() {
        
    }
    
    var updateArgCallCount = 0
    var updateArgHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg)
        }
        
    }
    var displayParamCallCount = 0
    var displayParamHandler: ((String) -> ())?
    func display(param: String)  {
        displayParamCallCount += 1
        if let displayParamHandler = displayParamHandler {
            return displayParamHandler(param)
        }
        
    }
    var updateCallCount = 0
    var updateHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        
    }
    var displayCallCount = 0
    var displayHandler: ((Double) -> ())?
    func display(param: Double)  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            return displayHandler(param)
        }
        
    }
}

class BazMock: Baz {
    
    init() {
        
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        
    }
    var updateArgCallCount = 0
    var updateArgHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg)
        }
        
    }
    var displayParamStringCallCount = 0
    var displayParamStringHandler: ((String) -> ())?
    func display(param: String)  {
        displayParamStringCallCount += 1
        if let displayParamStringHandler = displayParamStringHandler {
            return displayParamStringHandler(param)
        }
        
    }
    var displayCallCount = 0
    var displayHandler: ((Double) -> ())?
    func display(param: Double)  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            return displayHandler(param)
        }
        
    }
    var displayParamCallCount = 0
    var displayParamHandler: ((Int) -> ())?
    func display(param: Int)  {
        displayParamCallCount += 1
        if let displayParamHandler = displayParamHandler {
            return displayParamHandler(param)
        }
        
    }
    var showCallCount = 0
    var showHandler: ((String) -> ())?
    func show(param: String)  {
        showCallCount += 1
        if let showHandler = showHandler {
            return showHandler(param)
        }
        
    }
}
"""
