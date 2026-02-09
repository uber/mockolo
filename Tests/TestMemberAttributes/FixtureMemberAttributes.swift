import Foundation
import MockoloFramework

@Fixture enum memberAttributes {
    /// @mockable
    protocol AttributeProtocol {
        @available(*, deprecated, message: "Use newMethod instead")
        func oldMethod()
        
        @available(iOS 10.0, *)
        var availableProperty: String { get }
        
        @discardableResult
        func method() -> Int
        
        var normalProperty: Bool { get }
    }

    @Fixture enum expected {
        class AttributeProtocolMock: AttributeProtocol {
            init() { }
            init(availableProperty: String = "", normalProperty: Bool = false) {
                self.availableProperty = availableProperty
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

            private(set) var methodCallCount = 0
            var methodHandler: (() -> Int)?
            @discardableResult func method() -> Int {
                methodCallCount += 1
                if let methodHandler = methodHandler {
                    return methodHandler()
                }
                return 0
            }

            var normalProperty: Bool = false
        }
    }
}
