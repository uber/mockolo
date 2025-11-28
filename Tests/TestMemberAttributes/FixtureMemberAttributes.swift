import MockoloFramework

let methodAndVariableAttributes = """
/// @mockable
protocol AttributeProtocol {
    @available(*, deprecated, message: "Use newMethod instead")
    func oldMethod()
    
    @available(iOS 10.0, *)
    var availableProperty: String { get }
    
    @objc var objcProperty: Int { get }
    
    @objc func newMethod()
    
    @discardableResult
    func method() -> Int
    
    var normalProperty: Bool { get }
}
"""

let methodAndVariableAttributesMock = """
class AttributeProtocolMock: AttributeProtocol {
    init() { }
    init(availableProperty: String = "", objcProperty: Int = 0, normalProperty: Bool = false) {
        self.availableProperty = availableProperty
        self.objcProperty = objcProperty
        self.normalProperty = normalProperty
    }


    private(set) var oldMethodCallCount = 0
    var oldMethodHandler: (() -> ())?
    @available(*, deprecated, message: "Use newMethod instead")
    func oldMethod() {
        oldMethodCallCount += 1
        if let oldMethodHandler = oldMethodHandler {
            oldMethodHandler()
        }
        
    }

    @available(iOS 10.0, *)
    var availableProperty: String = ""

    @objc var objcProperty: Int = 0

    private(set) var newMethodCallCount = 0
    var newMethodHandler: (() -> ())?
    func newMethod() {
        newMethodCallCount += 1
        if let newMethodHandler = newMethodHandler {
            newMethodHandler()
        }
        
    }

    private(set) var methodCallCount = 0
    var methodHandler: (() -> Int)?
    func method() -> Int {
        methodCallCount += 1
        if let methodHandler = methodHandler {
            return methodHandler()
        }
        return 0
    }

    var normalProperty: Bool = false
}
"""

