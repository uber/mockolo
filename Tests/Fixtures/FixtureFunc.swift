import SwiftMockGenCore

let protocolWithFunc = """
import Foundation

/// \(MockAnnotation)
protocol Bar {
    func update(arg: Int) -> String
}
"""

let protocolWithFuncMock = """
\(HeaderDoc)
\(PoundIfMock)
import Foundation

class BarMock: Bar {
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
\(PoundEndIf)
"""
