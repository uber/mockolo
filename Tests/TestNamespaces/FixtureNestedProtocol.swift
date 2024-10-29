import MockoloFramework

let nestedProtocol = """
@MainActor final class FooView: UIView {
    /// \(String.mockAnnotation)
    @MainActor protocol Delegate: AnyObject {
        func onTapButton(_ button: UIButton)
    }

    weak var delegate: Delegate? 
}
"""

let nestedProtocolMock = """
extension FooView {
    class DelegateMock: Delegate {
        init() { }


        private(set) var onTapButtonCallCount = 0
        var onTapButtonHandler: ((UIButton) -> ())?
        func onTapButton(_ button: UIButton) {
            onTapButtonCallCount += 1
            if let onTapButtonHandler = onTapButtonHandler {
                onTapButtonHandler(button)
            }
            
        }
    }
}
"""
