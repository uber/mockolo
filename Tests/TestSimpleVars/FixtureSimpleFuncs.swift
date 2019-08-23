import MockoloFramework

let simpleFuncs = """
import Foundation

/// \(String.mockAnnotation)
protocol SimpleFunc {
    func update(arg: Int) -> String
}
"""

let simpleFuncsMock =
"""

import Foundation


class SimpleFuncMock: SimpleFunc {
    
    private var _doneInit = false
    
    init() {
        
        _doneInit = true
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
