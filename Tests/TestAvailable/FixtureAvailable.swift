import MockoloFramework

@Fixture enum deprecatedMembers {
    /// @mockable
    protocol Foo {
        @available(*, deprecated, message: "Message for bar")
        var bar: String { get set }

        @available(*, deprecated, message: "Message for baz")
        func baz() -> String
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }
            init(bar: String = "") {
                self.bar = bar
            }


            private(set) var barSetCallCount = 0
            @available(*, deprecated, message: "Message for bar")
            var bar: String = "" { didSet { barSetCallCount += 1 } }

            private(set) var bazCallCount = 0
            var bazHandler: (() -> String)?
            @available(*, deprecated, message: "Message for baz")
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

        @available(*, noasync)
        @discardableResult
        func string(for key: String) -> Result<String, Error>
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

            private(set) var stringCallCount = 0
            var stringHandler: ((String) -> Result<String, Error>)?
            @available(*, noasync)
            func string(for key: String) -> Result<String, Error> {
                stringCallCount += 1
                if let stringHandler = stringHandler {
                    return stringHandler(key)
                }
                fatalError("stringHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}

@Fixture enum memberPlatformAvailable {
    @available(macOS 99.0, *)
    struct AAA {}

    @available(macOS 80.0, *)
    struct BBB {}

    @available(iOS 99.0, *)
    struct CCC {}

    /// @mockable
    protocol Foo {
        @available(macOS 99.0, *)
        func aaa() -> AAA

        @available(macOS 80.0, *)
        func bbb() -> BBB

        @available(iOS 99.0, *)
        var ccc: CCC { get }
    }

    @Fixture enum expected {
        @available(iOS 99.0, *) @available(macOS 99.0, *) @available(macOS 80.0, *)
        class FooMock: Foo {
            init() { }
            init(ccc: CCC) {
                self._ccc = ccc
            }


            private(set) var aaaCallCount = 0
            var aaaHandler: (() -> AAA)?
            func aaa() -> AAA {
                aaaCallCount += 1
                if let aaaHandler = aaaHandler {
                    return aaaHandler()
                }
                fatalError("aaaHandler returns can't have a default value thus its handler must be set")
            }

            private(set) var bbbCallCount = 0
            var bbbHandler: (() -> BBB)?
            func bbb() -> BBB {
                bbbCallCount += 1
                if let bbbHandler = bbbHandler {
                    return bbbHandler()
                }
                fatalError("bbbHandler returns can't have a default value thus its handler must be set")
            }


            private var _ccc: CCC!
            var ccc: CCC {
                get { return _ccc }
                set { _ccc = newValue }
            }
        }
    }
}
