import SwiftMockGenCore

let simpleVar = """
import Foundation

/// \(MockAnnotation)
protocol SimpleVar {
    var name: Int { get set }
}
"""

let simpleVarMock = """
\(HeaderDoc)
\(PoundIfMock)
import Foundation
    
class SimpleVarMock: SimpleVar {
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
\(PoundEndIf)
"""
