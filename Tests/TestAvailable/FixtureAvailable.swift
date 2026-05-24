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

            @available(*, deprecated, message: "Use bar()")
            private(set) var bazCallCount = 0
            @available(*, deprecated, message: "Use bar()")
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

            @available(*, deprecated, message: "Use bar()")
            private(set) var bazCallCount = 0
            @available(*, deprecated, message: "Use bar()")
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


            @available(*, noasync)
            @available(*, deprecated, message: "Use async version")
            private(set) var barCallCount = 0
            @available(*, noasync)
            @available(*, deprecated, message: "Use async version")
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

            @available(*, deprecated, message: "Use name")
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

            @available(*, deprecated, message: "Use bar()")
            private let bazState = MockoloMutex(MockoloHandlerState<Never, @Sendable () -> String>())
            @available(*, deprecated, message: "Use bar()")
            var bazCallCount: Int {
                return bazState.withLock(\.callCount)
            }
            @available(*, deprecated, message: "Use bar()")
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

            @available(*, noasync)
            @available(*, deprecated, message: "Use get(for:) async throws")
            private let getForState = MockoloMutex(MockoloHandlerState<String, @Sendable (String) -> Result<String, Error>>())
            @available(*, noasync)
            @available(*, deprecated, message: "Use get(for:) async throws")
            var getForCallCount: Int {
                return getForState.withLock(\.callCount)
            }
            @available(*, noasync)
            @available(*, deprecated, message: "Use get(for:) async throws")
            var getForArgValues: [String] {
                return getForState.withLock(\.argValues).map(\.value)
            }
            @available(*, noasync)
            @available(*, deprecated, message: "Use get(for:) async throws")
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
