import MockoloFramework

let simpleVar = """
\(String.headerDoc)
import Foundation

/// \(String.mockAnnotation)
protocol SimpleVar {
    var name: Int { get set }
}
"""

let simpleVarMock = """
import Foundation

class SimpleVarMock: SimpleVar {
    init() {}
    init(name: Int = 0) {
        self.name = name
    }
    
    var nameSetCallCount = 0
    var underlyingName: Int = 0
    var name: Int {
        get {
            return underlyingName
        }
        set {
            underlyingName = newValue
            nameSetCallCount += 1
        }
    }
}
"""
