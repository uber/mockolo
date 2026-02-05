@Fixture enum actorProtocol {
    /// @mockable
    protocol Foo: Actor {
        func foo(arg: String) async -> Result<String, Error>
        var bar: Int { get }
    }

    @Fixture enum expected {
        actor FooMock: Foo {
            init() { }
            init(bar: Int = 0) {
                self.bar = bar
            }

            private let fooState = MockoloMutex(MockoloHandlerState<Never, (String) async -> Result<String, Error>>())
            nonisolated var fooCallCount: Int {
                return fooState.withLock(\.callCount)
            }
            nonisolated var fooHandler: ((String) async -> Result<String, Error>)? {
                get { fooState.withLock(\.handler) }
                set { fooState.withLock { $0.handler = newValue } }
            }
            func foo(arg: String) async -> Result<String, Error> {
                let fooHandler = fooState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let fooHandler = fooHandler {
                    return await fooHandler(arg)
                }
                fatalError("fooHandler returns can't have a default value thus its handler must be set")
            }

            var bar: Int = 0
        }
    }
}

@Fixture enum parentProtocolInheritsActor {
    protocol Bar: Actor {
        var bar: Int { get }
    }

    /// @mockable
    protocol Foo: Bar {
        func baz(arg: String) async -> Int
    }

    @Fixture enum expected {
        actor FooMock: Foo {
            init() { }
            init(bar: Int = 0) {
                self.bar = bar
            }


            var bar: Int = 0

            private let bazState = MockoloMutex(MockoloHandlerState<Never, (String) async -> Int>())
            nonisolated var bazCallCount: Int {
                return bazState.withLock(\.callCount)
            }
            nonisolated var bazHandler: ((String) async -> Int)? {
                get { bazState.withLock(\.handler) }
                set { bazState.withLock { $0.handler = newValue } }
            }
            func baz(arg: String) async -> Int {
                let bazHandler = bazState.withLock { state in
                    state.callCount += 1
                    return state.handler
                }
                if let bazHandler = bazHandler {
                    return await bazHandler(arg)
                }
                return 0
            }
        }
    }
}

@Fixture enum attributeAboveAnnotationComment {
    @MainActor
    /// @mockable
    protocol P0 {
    }

    @MainActor
    /// @mockable
    @available(iOS 18.0, *) protocol P1 {
    }

    @MainActor
    /// @mockable
    public class C0 {
        init() {}
    }

    @Fixture enum expected {
        class P0Mock: P0 {
            init() { }
        }

        class P1Mock: P1 {
            init() { }
        }

        public class C0Mock: C0 {
            override init() {
                super.init()
            }
        }
    }
}
