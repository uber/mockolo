import MockoloFramework

let availableDeprecated = """
/// @mockable
protocol AvailableDeprecated {
    @available(*, deprecated, message: "Use newMethod instead")
    func oldMethod() -> String
    
    func newMethod() -> String
}
"""

let availableDeprecatedMock = """
class AvailableDeprecatedMock: AvailableDeprecated {
    init() { }


    private(set) var oldMethodCallCount = 0
    var oldMethodHandler: (() -> String)?
    @available(*, deprecated, message: "Use newMethod instead")
    func oldMethod() -> String {
        oldMethodCallCount += 1
        if let oldMethodHandler = oldMethodHandler {
            return oldMethodHandler()
        }
        return ""
    }

    private(set) var newMethodCallCount = 0
    var newMethodHandler: (() -> String)?
    func newMethod() -> String {
        newMethodCallCount += 1
        if let newMethodHandler = newMethodHandler {
            return newMethodHandler()
        }
        return ""
    }
}
"""

