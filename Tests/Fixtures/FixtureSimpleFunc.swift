import SwiftMockGenCore

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
    
    var updateArgCallCount = 0
    var updateArgHandler: ((Int) -> (String))?
    func update(arg: Int) -> String {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg)
        }
        return ""
    }
}
"""
