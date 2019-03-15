import SwiftMockGenCore


let genericFunc = """
import Foundation

/// \(MockAnnotation)
protocol GenericFunc {
    func containsGeneric<T: StringProtocol, U: ExpressibleByIntegerLiteral>(arg1: T, arg2: @escaping (U) -> ()) -> ((T) -> (U))
}
"""

let genericFuncMock = """
\(HeaderDoc)
\(PoundIfMock)
import Foundation


class GenericFuncMock: GenericFunc {
init() {

}

var containsGenericCallCount = 0
var containsGenericHandler: ((Any, Any) -> (Any))?
func containsGeneric<T: StringProtocol, U: ExpressibleByIntegerLiteral>(arg1: T, arg2: @escaping (U) -> ()) -> ((T) -> (U)) {
containsGenericCallCount += 1
if let containsGenericHandler = containsGenericHandler {
return containsGenericHandler(arg1, arg2) as! ((T) -> (U))
}
fatalError("containsGenericHandler returns can't have a default value thus its handler must be set")
}
}
\(PoundEndIf)
"""
