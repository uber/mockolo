import MockoloFramework

let simpleFunc = """
import Foundation

/// \(String.mockAnnotation)
protocol SimpleFunc {
    func update(arg: Int) -> String
}
"""

let simpleFuncMock = """
import Foundation

class SimpleFuncMock: SimpleFunc {
    
    init() {
        
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int) -> (String))?
    func update(arg: Int) -> String {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        return ""
    }
}
"""
