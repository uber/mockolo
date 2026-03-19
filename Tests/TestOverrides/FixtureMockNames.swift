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

// MARK: - Base Protocol - Variations

let baseProtocol_NoCustomization =
"""
/// @mockable()
protocol BaseProtocol {
    func register()
    var counter: Int { get } 
}
"""

let baseProtocol_MockedAs_BaseProtocolMock =
"""
/// @mockable(override: name = BaseProtocolMock)
protocol BaseProtocol {
    func register()
    var counter: Int { get } 
}
"""

let baseProtocol_MockedAs_BaseMock =
"""
/// @mockable(override: name = BaseMock)
protocol BaseProtocol {
    func register()
    var counter: Int { get } 
}
"""

let baseProtocol_MockedAs_FakeBase =
"""
/// @mockable(override: name = FakeBase)
protocol BaseProtocol {
    func register()
    var counter: Int { get } 
}
"""

// MARK: - Base Mocks - Variations

let baseProtocolMock_Named_BaseProtocolMock =
"""
class BaseProtocolMock: BaseProtocol {
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

let baseProtocolMock_Named_BaseMock =
"""
class BaseMock: BaseProtocol {
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

let baseProtocolMock_Named_FakeBase =
"""
class FakeBase: BaseProtocol {
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

// MARK: - Derived Protocol - Variations

let derivedProtocol_NoCustomization =
"""
/// @mockable()
protocol DerivedProtocol : BaseProtocol {
    func like()
    func subscribe() 
}
"""

let derivedProtocol_MockedAs_DerivedProtocolMock =
"""
/// @mockable(override: name = DerivedProtocolMock)
protocol DerivedProtocol : BaseProtocol {
    func like()
    func subscribe() 
}
"""

let derivedProtocol_MockedAs_DerivedMock =
"""
/// @mockable(override: name = DerivedMock)
protocol DerivedProtocol : BaseProtocol {
    func like()
    func subscribe() 
}
"""

let derivedProtocol_MockedAs_FakeDerived =
"""
/// @mockable(override: name = FakeDerived)
protocol DerivedProtocol : BaseProtocol {
    func like()
    func subscribe() 
}
"""

// MARK: - Derived Mocks - Variations

let derivedMock_Named_DerivedProtocolMock =
"""
class DerivedProtocolMock: DerivedProtocol {
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

let derivedMock_Named_DerivedMock =
"""
class DerivedMock: DerivedProtocol {
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

let derivedMock_Named_FakeDerived =
"""
class FakeDerived: DerivedProtocol {
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

