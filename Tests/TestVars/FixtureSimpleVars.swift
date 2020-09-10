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
    private(set) var nameSetCallCount = 0
    var name: Int = 0 { didSet { nameSetCallCount += 1 } }
}

"""

let simpleVarsFinalMock = """

import Foundation

final class SimpleVarMock: SimpleVar {
    
    
    
    init() {  }
    init(name: Int = 0) {
        self.name = name
        
    }
    private(set) var nameSetCallCount = 0
    var name: Int = 0 { didSet { nameSetCallCount += 1 } }
}

"""
