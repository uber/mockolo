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
}

class BarMock: Bar {
    
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
}

"""
