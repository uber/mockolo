#if compiler(>=6.0)
@Fixture enum sendableSubscript {
    /// @mockable
    public protocol SendableSubscriptProtocol: Sendable {
        subscript(key: Int) -> String { get set }
        subscript(index: String) -> Int? { get }
    }

    @Fixture(includesConcurrencyHelpers: true)
    enum expected {
        public final class SendableSubscriptProtocolMock: SendableSubscriptProtocol, @unchecked Sendable {
            public init() { }


            private let subscriptState = MockoloMutex(MockoloHandlerState<Never, @Sendable (Int) -> String>())
            public var subscriptCallCount: Int {
                return subscriptState.withLock(\.callCount)
            }
            public var subscriptHandler: (@Sendable (Int) -> String)? {
                get { subscriptState.withLock(\.handler) }
                set { subscriptState.withLock { $0.handler = newValue } }
            }
            private let subscriptSetState = MockoloMutex(MockoloHandlerState<Never, @Sendable (Int, String) -> ()>())
            public var subscriptSetCallCount: Int {
                return subscriptSetState.withLock(\.callCount)
            }
            public var subscriptSetHandler: (@Sendable (Int, String) -> ())? {
                get { subscriptSetState.withLock(\.handler) }
                set { subscriptSetState.withLock { $0.handler = newValue } }
            }
            public subscript(key: Int) -> String {
                get {
                let subscriptHandler = subscriptState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let subscriptHandler = subscriptHandler {
                    return subscriptHandler(key)
                }
                return ""
                }
                set {
                let subscriptSetHandler = subscriptSetState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                subscriptSetHandler?(key, newValue)
                }
            }

            private let subscriptIndexState = MockoloMutex(MockoloHandlerState<Never, @Sendable (String) -> Int?>())
            public var subscriptIndexCallCount: Int {
                return subscriptIndexState.withLock(\.callCount)
            }
            public var subscriptIndexHandler: (@Sendable (String) -> Int?)? {
                get { subscriptIndexState.withLock(\.handler) }
                set { subscriptIndexState.withLock { $0.handler = newValue } }
            }
            public subscript(index: String) -> Int? {
                get {
                let subscriptIndexHandler = subscriptIndexState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let subscriptIndexHandler = subscriptIndexHandler {
                    return subscriptIndexHandler(index)
                }
                return nil
                }
            }
        }
    }
}

@Fixture enum sendableProtocol {
    /// @mockable
    public protocol SendableProtocol: Sendable {
        func update(arg: Int) -> String
        func update(arg0: some Sendable, arg1: AnyObject) async throws
    }

    @Fixture(includesConcurrencyHelpers: true)
    enum expected {
        public final class SendableProtocolMock: SendableProtocol, @unchecked Sendable {
            public init() { }


            private let updateState = MockoloMutex(MockoloHandlerState<Int, @Sendable (Int) -> String>())
            public var updateCallCount: Int {
                return updateState.withLock(\.callCount)
            }
            public var updateArgValues: [Int] {
                return updateState.withLock(\.argValues).map(\.value)
            }
            public var updateHandler: (@Sendable (Int) -> String)? {
                get { updateState.withLock(\.handler) }
                set { updateState.withLock { $0.handler = newValue } }
            }
            public func update(arg: Int) -> String {
                warnIfNotSendable(arg)
                let updateHandler = updateState.withLock { state in
                    state.callCount += 1
                    state.argValues.append(.init((arg)))
                    return state.handler
                }
                if let updateHandler = updateHandler {
                    return updateHandler(arg)
                }
                return ""
            }

            private let updateArg0State = MockoloMutex(MockoloHandlerState<(arg0: any Sendable, arg1: AnyObject), @Sendable (any Sendable, AnyObject) async throws -> ()>())
            public var updateArg0CallCount: Int {
                return updateArg0State.withLock(\.callCount)
            }
            public var updateArg0ArgValues: [(arg0: any Sendable, arg1: AnyObject)] {
                return updateArg0State.withLock(\.argValues).map(\.value)
            }
            public var updateArg0Handler: (@Sendable (any Sendable, AnyObject) async throws -> ())? {
                get { updateArg0State.withLock(\.handler) }
                set { updateArg0State.withLock { $0.handler = newValue } }
            }
            public func update(arg0: some Sendable, arg1: AnyObject) async throws {
                warnIfNotSendable(arg0, arg1)
                let updateArg0Handler = updateArg0State.withLock { state in
                    state.callCount += 1
                    state.argValues.append(.init((arg0, arg1)))
                    return state.handler
                }
                if let updateArg0Handler = updateArg0Handler {
                    try await updateArg0Handler(arg0, arg1)
                }

            }
        }
    }
}

@Fixture enum uncheckedSendableClass {
    /// @mockable
    public class UncheckedSendableClass: @unchecked Sendable {
        func update(arg: Int) -> String {
            return ""
        }
    }

    @Fixture(includesConcurrencyHelpers: true)
    enum expected {
        public final class UncheckedSendableClassMock: UncheckedSendableClass, @unchecked Sendable {
            public override init() { }


            private let updateState = MockoloMutex(MockoloHandlerState<Never, @Sendable (Int) -> String>())
            var updateCallCount: Int {
                return updateState.withLock(\.callCount)
            }
            var updateHandler: (@Sendable (Int) -> String)? {
                get { updateState.withLock(\.handler) }
                set { updateState.withLock { $0.handler = newValue } }
            }
            override func update(arg: Int) -> String {
                let updateHandler = updateState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let updateHandler = updateHandler {
                    return updateHandler(arg)
                }
                return ""
            }
        }
    }
}

@Fixture enum confirmedSendableProtocol {
    public protocol SendableSendable: Sendable {
        func update(arg: Int) -> String
    }

    /// @mockable
    public protocol ConfirmedSendableProtocol: SendableSendable {
    }

    @Fixture(includesConcurrencyHelpers: true)
    enum expected {
        public final class ConfirmedSendableProtocolMock: ConfirmedSendableProtocol, @unchecked Sendable {
            public init() { }


            private let updateState = MockoloMutex(MockoloHandlerState<Never, @Sendable (Int) -> String>())
            public var updateCallCount: Int {
                return updateState.withLock(\.callCount)
            }
            public var updateHandler: (@Sendable (Int) -> String)? {
                get { updateState.withLock(\.handler) }
                set { updateState.withLock { $0.handler = newValue } }
            }
            public func update(arg: Int) -> String {
                let updateHandler = updateState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let updateHandler = updateHandler {
                    return updateHandler(arg)
                }
                return ""
            }
        }
    }
}

@Fixture enum availableSendableProtocol {
    @available(macOS 99.0, *)
    struct Bar {}

    /// @mockable
    @available(macOS 99.0, *)
    protocol Foo: Sendable {
        func bar() -> Bar
    }

    @Fixture(includesConcurrencyHelpers: true)
    enum expected {
        @available(macOS 99.0, *)
        final class FooMock: Foo, @unchecked Sendable {
            init() { }


            private let barState = MockoloMutex(MockoloHandlerState<Never, @Sendable () -> Bar>())
            var barCallCount: Int {
                return barState.withLock(\.callCount)
            }
            var barHandler: (@Sendable () -> Bar)? {
                get { barState.withLock(\.handler) }
                set { barState.withLock { $0.handler = newValue } }
            }
            func bar() -> Bar {
                let barHandler = barState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let barHandler = barHandler {
                    return barHandler()
                }
                fatalError("barHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}
#endif
