import MockoloFramework

let simpleVars = """
\(String.headerDoc)
import Foundation

/// \(String.mockAnnotation)
protocol SimpleVar {
    var name: Int { get set }
}
"""

let simpleVarsMock = """

import Foundation

class SimpleVarMock: SimpleVar {
    
    
    
    init() {  }
    init(name: Int = 0) {
        self.name = name
        
    }
    var nameSetCallCount = 0
    var name: Int = 0 { didSet { nameSetCallCount += 1 } }
}

"""
