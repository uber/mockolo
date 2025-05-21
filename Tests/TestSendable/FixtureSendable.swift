#if compiler(>=6.0)
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
#endif
