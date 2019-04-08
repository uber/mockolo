import SwiftMockGenCore


let duplicates1 = """
import UIKit

/// \(String.mockAnnotation)
protocol DuplicateFuncNames {
func display()
func display(x: Int)
func display(y: Int)
func update()
func update() -> Int
func update(arg: Int)
func update(arg: Float)
}
"""

let duplicateMock1 = """
import UIKit

class DuplicateFuncNamesMock: DuplicateFuncNames {
    
    init() {
        
    }
    
    var displayCallCount = 0
    var displayHandler: (() -> ())?
    func display()  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            return displayHandler()
        }
        
    }
    var displayXCallCount = 0
    var displayXHandler: ((Int) -> ())?
    func display(x: Int)  {
        displayXCallCount += 1
        if let displayXHandler = displayXHandler {
            return displayXHandler(x)
        }
        
    }
    var displayYCallCount = 0
    var displayYHandler: ((Int) -> ())?
    func display(y: Int)  {
        displayYCallCount += 1
        if let displayYHandler = displayYHandler {
            return displayYHandler(y)
        }
        
    }
    var updateCallCount = 0
    var updateHandler: (() -> ())?
    func update()  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler()
        }
        
    }
    var updateIntCallCount = 0
    var updateIntHandler: (() -> (Int))?
    func update() -> Int {
        updateIntCallCount += 1
        if let updateIntHandler = updateIntHandler {
            return updateIntHandler()
        }
        return 0
    }
    var updateArgCallCount = 0
    var updateArgHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg)
        }
        
    }
    var updateArgFloatCallCount = 0
    var updateArgFloatHandler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArgFloatCallCount += 1
        if let updateArgFloatHandler = updateArgFloatHandler {
            return updateArgFloatHandler(arg)
        }
        
    }
}
"""


