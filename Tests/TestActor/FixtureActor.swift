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
            private(set) var fooCallCount = 0
            var fooHandler: ((String) async -> Result<String, Error>)?
            func foo(arg: String) async -> Result<String, Error> {
                fooCallCount += 1
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

            private(set) var bazCallCount = 0
            var bazHandler: ((String) async -> Int)?
            func baz(arg: String) async -> Int {
                bazCallCount += 1
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
