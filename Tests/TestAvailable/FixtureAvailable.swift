import MockoloFramework

@Fixture enum memberAvailableFunc {
    /// @mockable
    protocol Foo {
        func bar() -> String
        @available(*, deprecated, message: "Use bar()")
        func baz() -> String
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }


            private(set) var barCallCount = 0
            var barHandler: (() -> String)?
            func bar() -> String {
                barCallCount += 1
                if let barHandler = barHandler {
                    return barHandler()
                }
                return ""
            }

            private(set) var bazCallCount = 0
            var bazHandler: (() -> String)?
            @available(*, deprecated, message: "Use bar()")
            func baz() -> String {
                bazCallCount += 1
                if let bazHandler = bazHandler {
                    return bazHandler()
                }
                return ""
            }
        }
    }
}

@Fixture enum protocolAndMemberAvailable {
    /// @mockable
    @available(macOS 13.0, *)
    protocol Foo {
        func bar() -> String
        @available(*, deprecated, message: "Use bar()")
        func baz() -> String
    }

    @Fixture enum expected {
        @available(macOS 13.0, *)
        class FooMock: Foo {
            init() { }


            private(set) var barCallCount = 0
            var barHandler: (() -> String)?
            func bar() -> String {
                barCallCount += 1
                if let barHandler = barHandler {
                    return barHandler()
                }
                return ""
            }

            private(set) var bazCallCount = 0
            var bazHandler: (() -> String)?
            @available(*, deprecated, message: "Use bar()")
            func baz() -> String {
                bazCallCount += 1
                if let bazHandler = bazHandler {
                    return bazHandler()
                }
                return ""
            }
        }
    }
}

@Fixture enum multipleAvailableOnMethod {
    /// @mockable
    protocol Foo {
        @available(*, noasync)
        @available(*, deprecated, message: "Use async version")
        func bar() -> String
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }


            private(set) var barCallCount = 0
            var barHandler: (() -> String)?
            @available(*, noasync)
            @available(*, deprecated, message: "Use async version")
            func bar() -> String {
                barCallCount += 1
                if let barHandler = barHandler {
                    return barHandler()
                }
                return ""
            }
        }
    }
}

@Fixture enum memberAvailableVar {
    /// @mockable
    protocol Foo {
        var name: String { get }
        @available(*, deprecated, message: "Use name")
        var data: String { get set }
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }
            init(name: String = "", data: String = "") {
                self.name = name
                self.data = data
            }

            var name: String = ""

            private(set) var dataSetCallCount = 0
            @available(*, deprecated, message: "Use name")
            var data: String = "" { didSet { dataSetCallCount += 1 } }
        }
    }
}

#if compiler(>=6.0)
@Fixture enum memberAvailableSendable {
    /// @mockable
    protocol Foo: Sendable {
        func bar() -> String
        @available(*, deprecated, message: "Use bar()")
        func baz() -> String
    }

    @Fixture(includesConcurrencyHelpers: true) enum expected {
        final class FooMock: Foo, @unchecked Sendable {
            init() { }


            private let barState = MockoloMutex(MockoloHandlerState<Never, @Sendable () -> String>())
            var barCallCount: Int {
                return barState.withLock(\.callCount)
            }
            var barHandler: (@Sendable () -> String)? {
                get { barState.withLock(\.handler) }
                set { barState.withLock { $0.handler = newValue } }
            }
            func bar() -> String {
                let barHandler = barState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let barHandler = barHandler {
                    return barHandler()
                }
                return ""
            }

            private let bazState = MockoloMutex(MockoloHandlerState<Never, @Sendable () -> String>())
            var bazCallCount: Int {
                return bazState.withLock(\.callCount)
            }
            var bazHandler: (@Sendable () -> String)? {
                get { bazState.withLock(\.handler) }
                set { bazState.withLock { $0.handler = newValue } }
            }
            @available(*, deprecated, message: "Use bar()")
            func baz() -> String {
                let bazHandler = bazState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let bazHandler = bazHandler {
                    return bazHandler()
                }
                return ""
            }
        }
    }
}

@Fixture enum reportedIssue {
    /// @mockable
    protocol StorageInput: Sendable {
        func get(for key: String) async throws -> String

        @available(*, noasync)
        @available(*, deprecated, message: "Use get(for:) async throws")
        func get(for key: String) -> Result<String, Error>
    }

    @Fixture(includesConcurrencyHelpers: true) enum expected {
        final class StorageInputMock: StorageInput, @unchecked Sendable {
            init() { }


            private let getState = MockoloMutex(MockoloHandlerState<String, @Sendable (String) async throws -> String>())
            var getCallCount: Int {
                return getState.withLock(\.callCount)
            }
            var getArgValues: [String] {
                return getState.withLock(\.argValues).map(\.value)
            }
            var getHandler: (@Sendable (String) async throws -> String)? {
                get { getState.withLock(\.handler) }
                set { getState.withLock { $0.handler = newValue } }
            }
            func get(for key: String) async throws -> String {
                warnIfNotSendable(key)
                let getHandler = getState.withLock { state in
                    state.callCount += 1
                    state.argValues.append(.init((key)))
                    return state.handler
                }
                if let getHandler = getHandler {
                    return try await getHandler(key)
                }
                return ""
            }

            private let getForState = MockoloMutex(MockoloHandlerState<String, @Sendable (String) -> Result<String, Error>>())
            var getForCallCount: Int {
                return getForState.withLock(\.callCount)
            }
            var getForArgValues: [String] {
                return getForState.withLock(\.argValues).map(\.value)
            }
            var getForHandler: (@Sendable (String) -> Result<String, Error>)? {
                get { getForState.withLock(\.handler) }
                set { getForState.withLock { $0.handler = newValue } }
            }
            @available(*, noasync)
            @available(*, deprecated, message: "Use get(for:) async throws")
            func get(for key: String) -> Result<String, Error> {
                warnIfNotSendable(key)
                let getForHandler = getForState.withLock { state in
                    state.callCount += 1
                    state.argValues.append(.init((key)))
                    return state.handler
                }
                if let getForHandler = getForHandler {
                    return getForHandler(key)
                }
                fatalError("getForHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}

@Fixture enum duplicatedAttributes {
    /// @mockable
    protocol StorageInput: Sendable {
        func put(_ value: String, for key: String) async throws
        func string(for key: String) async throws -> String

        @available(*, noasync)
        @available(*, deprecated, message: "Use put(_:for:) async throws")
        @discardableResult func set(_ value: String, for key: String) -> Result<Void, Error>

        @available(*, noasync)
        @available(*, deprecated, message: "Use string(for:) async throws")
        func string(for key: String) -> Result<String, Error>
    }

    @Fixture(includesConcurrencyHelpers: true) enum expected {
        final class StorageInputMock: StorageInput, @unchecked Sendable {
            init() { }


            private let putState = MockoloMutex(MockoloHandlerState<(value: String, key: String), @Sendable (String, String) async throws -> ()>())
            var putCallCount: Int {
                return putState.withLock(\.callCount)
            }
            var putArgValues: [(value: String, key: String)] {
                return putState.withLock(\.argValues).map(\.value)
            }
            var putHandler: (@Sendable (String, String) async throws -> ())? {
                get { putState.withLock(\.handler) }
                set { putState.withLock { $0.handler = newValue } }
            }
            func put(_ value: String, for key: String) async throws {
                warnIfNotSendable(value, key)
                let putHandler = putState.withLock { state in
                    state.callCount += 1
                    state.argValues.append(.init((value, key)))
                    return state.handler
                }
                if let putHandler = putHandler {
                    try await putHandler(value, key)
                }

            }

            private let stringState = MockoloMutex(MockoloHandlerState<String, @Sendable (String) async throws -> String>())
            var stringCallCount: Int {
                return stringState.withLock(\.callCount)
            }
            var stringArgValues: [String] {
                return stringState.withLock(\.argValues).map(\.value)
            }
            var stringHandler: (@Sendable (String) async throws -> String)? {
                get { stringState.withLock(\.handler) }
                set { stringState.withLock { $0.handler = newValue } }
            }
            func string(for key: String) async throws -> String {
                warnIfNotSendable(key)
                let stringHandler = stringState.withLock { state in
                    state.callCount += 1
                    state.argValues.append(.init((key)))
                    return state.handler
                }
                if let stringHandler = stringHandler {
                    return try await stringHandler(key)
                }
                return ""
            }

            private let setState = MockoloMutex(MockoloHandlerState<(value: String, key: String), @Sendable (String, String) -> Result<Void, Error>>())
            var setCallCount: Int {
                return setState.withLock(\.callCount)
            }
            var setArgValues: [(value: String, key: String)] {
                return setState.withLock(\.argValues).map(\.value)
            }
            var setHandler: (@Sendable (String, String) -> Result<Void, Error>)? {
                get { setState.withLock(\.handler) }
                set { setState.withLock { $0.handler = newValue } }
            }
            @available(*, noasync)
            @available(*, deprecated, message: "Use put(_:for:) async throws")
            func set(_ value: String, for key: String) -> Result<Void, Error> {
                warnIfNotSendable(value, key)
                let setHandler = setState.withLock { state in
                    state.callCount += 1
                    state.argValues.append(.init((value, key)))
                    return state.handler
                }
                if let setHandler = setHandler {
                    return setHandler(value, key)
                }
                fatalError("setHandler returns can't have a default value thus its handler must be set")
            }

            private let stringForState = MockoloMutex(MockoloHandlerState<String, @Sendable (String) -> Result<String, Error>>())
            var stringForCallCount: Int {
                return stringForState.withLock(\.callCount)
            }
            var stringForArgValues: [String] {
                return stringForState.withLock(\.argValues).map(\.value)
            }
            var stringForHandler: (@Sendable (String) -> Result<String, Error>)? {
                get { stringForState.withLock(\.handler) }
                set { stringForState.withLock { $0.handler = newValue } }
            }
            @available(*, noasync)
            @available(*, deprecated, message: "Use string(for:) async throws")
            func string(for key: String) -> Result<String, Error> {
                warnIfNotSendable(key)
                let stringForHandler = stringForState.withLock { state in
                    state.callCount += 1
                    state.argValues.append(.init((key)))
                    return state.handler
                }
                if let stringForHandler = stringForHandler {
                    return stringForHandler(key)
                }
                fatalError("stringForHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}
#endif

@Fixture enum memberPlatformAvailable {
    /// @mockable
    protocol Foo {
        @available(iOS 15.0, *)
        func bar() -> String
    }

    @Fixture enum expected {
        @available(iOS 15.0, *)
        class FooMock: Foo {
            init() { }


            private(set) var barCallCount = 0
            var barHandler: (() -> String)?
            func bar() -> String {
                barCallCount += 1
                if let barHandler = barHandler {
                    return barHandler()
                }
                return ""
            }
        }
    }
}
