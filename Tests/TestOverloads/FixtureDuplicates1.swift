import MockoloFramework


let overload3 = """
import UIKit

/// \(String.mockAnnotation)
protocol Foo {
func display()
func display(x: Int)
func display(y: Int)
func update()
func update() -> Int
func update(arg: Int)
func update(arg: Float)
}
"""

let overloadMock3 =
"""

import UIKit


class FooMock: Foo {
    init() { }


    private(set) var displayCallCount = 0
    var displayHandler: (() -> ())?
    func display()  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            displayHandler()
        }
        
    }

    private(set) var displayXCallCount = 0
    var displayXHandler: ((Int) -> ())?
    func display(x: Int)  {
        displayXCallCount += 1
        if let displayXHandler = displayXHandler {
            displayXHandler(x)
        }
        
    }

    private(set) var displayYCallCount = 0
    var displayYHandler: ((Int) -> ())?
    func display(y: Int)  {
        displayYCallCount += 1
        if let displayYHandler = displayYHandler {
            displayYHandler(y)
        }
        
    }

    private(set) var updateCallCount = 0
    var updateHandler: (() -> ())?
    func update()  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler()
        }
        
    }

    private(set) var updateIntCallCount = 0
    var updateIntHandler: (() -> (Int))?
    func update() -> Int {
        updateIntCallCount += 1
        if let updateIntHandler = updateIntHandler {
            return updateIntHandler()
        }
        return 0
    }

    private(set) var updateArgCallCount = 0
    var updateArgHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            updateArgHandler(arg)
        }
        
    }

    private(set) var updateArgFloatCallCount = 0
    var updateArgFloatHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArgFloatCallCount += 1
        if let updateArgFloatHandler = updateArgFloatHandler {
            updateArgFloatHandler(arg)
        }
        
    }
}

"""
