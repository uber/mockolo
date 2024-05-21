import Foundation

let asyncFunctionGlobalActorOverride =
"""
/// \(String.mockAnnotation)(override: asyncFunctionGlobalActor = MainActor)
protocol FooProtocol {
    func asyncFunction() async -> Bool
    func syncFunction() -> Bool
}
"""

let asyncFunctionGlobalActorOverrideMock =
"""
class FooProtocolMock: FooProtocol {
    init() { }


    private(set) var asyncFunctionCallCount = 0
    var asyncFunctionHandler: (() async -> (Bool))?
    @MainActor func asyncFunction() async -> Bool {
        asyncFunctionCallCount += 1
        if let asyncFunctionHandler = asyncFunctionHandler {
            return await asyncFunctionHandler()
        }
        return false
    }

    private(set) var syncFunctionCallCount = 0
    var syncFunctionHandler: (() -> (Bool))?
    func syncFunction() -> Bool {
        syncFunctionCallCount += 1
        if let syncFunctionHandler = syncFunctionHandler {
            return syncFunctionHandler()
        }
        return false
    }
}
"""
