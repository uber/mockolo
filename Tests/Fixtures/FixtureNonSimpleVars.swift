import SwiftMockGenCore

let nonSimpleVars = """
import Foundation

/// \(String.mockAnnotation)
protocol NonSimpleVars {
var dict: Dictionary<String, Int> { get set }
}
"""

let nonSimpleVarsMock = """

\(String.headerDoc)
\(String.poundIfMock)
import Foundation

class NonSimpleVarsMock: NonSimpleVars {
init(dict: Dictionary<String, Int> = Dictionary<String, Int>()) {
self.dict = dict
}

var dictSetCallCount = 0
var underlyingDict: Dictionary<String, Int> = Dictionary<String, Int>()
var dict: Dictionary<String, Int> {
get {
return underlyingDict
}
set {
underlyingDict = newValue
dictSetCallCount += 1
}
}
}
\(String.poundEndIf)
"""
