import MockoloFramework

@Fixture enum sendableProtocol {
    /// @mockable
    public protocol SendableProtocol: Sendable {
        func update(arg: Int) -> String
        func update(arg0: some Sendable, arg1: AnyObject) async throws
    }

    @Fixture enum expected {
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

            private let updateArg0State = MockoloMutex(MockoloHandlerState<(arg0: Any, arg1: AnyObject), @Sendable (Any, AnyObject) async throws -> ()>())
            public var updateArg0CallCount: Int {
                return updateArg0State.withLock(\.callCount)
            }
            public var updateArg0ArgValues: [(arg0: Any, arg1: AnyObject)] {
                return updateArg0State.withLock(\.argValues).map(\.value)
            }
            public var updateArg0Handler: (@Sendable (Any, AnyObject) async throws -> ())? {
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

    @Fixture enum expected {
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

    @Fixture enum expected {
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

import Foundation

@Fixture enum generatedConcurrencyHelpers {
    /// @mockable
    public protocol SendableProtocol: Sendable {
    }

    @Fixture enum expected {
        public final class SendableProtocolMock: SendableProtocol, @unchecked Sendable {
            public init() { }
        }

        fileprivate func warnIfNotSendable<each T>(function: String = #function, _: repeat each T) {
            print("At \(function), the captured arguments are not Sendable, it is not concurrency-safe.")
        }

        fileprivate func warnIfNotSendable<each T: Sendable>(function: String = #function, _: repeat each T) {
        }

        /// Will be replaced to `Synchronization.Mutex` in future.
        fileprivate final class MockoloMutex<Value>: @unchecked Sendable {
            private let lock = NSLock()
            private var value: Value
            init(_ initialValue: Value) {
                self.value = initialValue
            }
        #if compiler(>=6.0)
            borrowing func withLock<Result, E: Error>(_ body: (inout sending Value) throws(E) -> Result) throws(E) -> sending Result {
                lock.lock()
                defer { lock.unlock() }
                return try body(&value)
            }
        #else
            func withLock<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
                lock.lock()
                defer { lock.unlock() }
                return try body(&value)
            }
        #endif
        }

        fileprivate struct MockoloUnsafeTransfer<Value>: @unchecked Sendable {
            var value: Value
            init(_ value: Value) {
                self.value = value
            }
        }

        fileprivate struct MockoloHandlerState<Arg, Handler> {
            var argValues: [MockoloUnsafeTransfer<Arg>] = []
            var handler: Handler? = nil
            var callCount: Int = 0
        }
    }
}
