import MockoloFramework


let duplicateSigInheritance4 = """
/// @mockable
protocol Foo {
func update(arg: Int)
}

/// @mockable
protocol Bar: Foo {
func update(arg: Int)
}

/// @mockable
protocol Baz: Foo, Bar {
}
"""

let duplicateSigInheritanceMock4 =
"""

class FooMock: Foo {
    
    
    
    init() {
        
        
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int) {
        updateCallCount += 1
        
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }
}

class BarMock: Bar {
    
    
    
    init() {
        
        
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int) {
        updateCallCount += 1
        
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }
}

class BazMock: Baz {
    
    
    
    init() {
        
        
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int) -> ())?
    func update(arg: Int) {
        updateCallCount += 1
        
        if let updateHandler = updateHandler {
            updateHandler(arg)
        }
        
    }
}

"""
