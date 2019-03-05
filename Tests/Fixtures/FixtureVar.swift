import SwiftMockGenCore

let protocolWithVar = """
import Foundation

/// \(MockAnnotation)
protocol Foo {
    var name: Int { get set }
}
"""

let protocolWithVarMock = """
\(HeaderDoc)
\(PoundIfMock)
import Foundation
    
class FooMock: Foo {
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
