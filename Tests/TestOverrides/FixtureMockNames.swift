import Foundation

let nameOverride =
"""
/// @mockable(override: name = FooMock)
protocol FooProtocol {
    func display()
}
"""

let nameOverrideMock =
"""
class FooMock: FooProtocol {
    init() { }

    private(set) var displayCallCount = 0
    var displayHandler: (() -> ())?
    func display() {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            displayHandler()
        }
    }
}
"""

func mockableDeclaration(customName: String?) -> String {
    switch customName {
    case .some(let customName):
        "/// @mockable(override: name = \(customName))"
    case .none:
        "/// @mockable()"
    }
}

func baseProtocol(customName: String?) -> String {
    """
    \(mockableDeclaration(customName: customName))
    protocol BaseProtocol {
        func register()
        var counter: Int { get } 
    }
    """
}

func baseMock(customName: String?) -> String {
    """
    class \(customName ?? "BaseProtocolMock"): BaseProtocol {
        init() { }
        init(counter: Int = 0) {
            self.counter = counter
        }
        private(set) var registerCallCount = 0
        var registerHandler: (() -> ())?
        func register() {
            registerCallCount += 1
            if let registerHandler = registerHandler {
                registerHandler()
            }
        }
        var counter: Int = 0
    }
    """
}

func derivedProtocol(customName: String?) -> String {
    """
    \(mockableDeclaration(customName: customName))
    protocol DerivedProtocol : BaseProtocol {
        func like()
        func subscribe() 
    }
    """
}

func derivedMock(customName: String?) -> String {
    """
    class \(customName ?? "DerivedProtocolMock"): DerivedProtocol {
        init() { }
        init(counter: Int = 0) {
            self.counter = counter
        }

        private(set) var likeCallCount = 0
        var likeHandler: (() -> ())?
        func like() {
            likeCallCount += 1
            if let likeHandler = likeHandler {
                likeHandler()
            }
            
        }

        private(set) var subscribeCallCount = 0
        var subscribeHandler: (() -> ())?
        func subscribe() {
            subscribeCallCount += 1
            if let subscribeHandler = subscribeHandler {
                subscribeHandler()
            }
            
        }
        private(set) var registerCallCount = 0
        var registerHandler: (() -> ())?
        func register() {
            registerCallCount += 1
            if let registerHandler = registerHandler {
                registerHandler()
            }
        }
        var counter: Int = 0
    }
    """
}
