import MockoloFramework

@Fixture enum patNameCollision {
    /// @mockable
    protocol Foo {
        associatedtype T
    }

    /// @mockable
    protocol Bar {
        associatedtype T: StringProtocol
    }

    /// @mockable(typealias: T = Hashable & Codable)
    protocol Cat {
        associatedtype T
    }

    /// @mockable
    protocol Baz: Foo, Bar {
    }

    protocol Animal {
        associatedtype T: Identifiable & Sendable where T.ID == String
    }

    /// @mockable
    protocol Dog: Bar, Animal {
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }
            typealias T = Any
        }

        class BarMock<T: StringProtocol>: Bar {
            init() { }
        }

        class CatMock: Cat {
            init() { }
            typealias T = Hashable & Codable
        }

        class BazMock<T>: Baz where T: StringProtocol {
            init() { }
        }

        class DogMock<T>: Dog where T: StringProtocol, T: Identifiable & Sendable, T.ID == String {
            init() {}
        }
    }
}

@Fixture enum simplePat {
    protocol Foo {}

    /// @mockable(typealias: T = String)
    public protocol FooBar: Foo {
        associatedtype T
    }

    @Fixture enum parent {
        public class FooMock: Foo {
            public init() { }

            public typealias T = String
        }
    }

    @Fixture enum expected {
        public class FooBarMock: FooBar {
            public init() { }

            public typealias T = String
        }
    }
}

@Fixture enum patOverride {
    /// @mockable(typealias: T = Any; U = Bar; R = (String, Int); S = AnyObject)
    protocol Foo {
        associatedtype T
        associatedtype U
        associatedtype R
        associatedtype S
    }

    typealias Bar = ()

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            typealias T = Any
            typealias U = Bar
            typealias R = (String, Int)
            typealias S = AnyObject
        }
    }
}

@Fixture enum protocolWithTypealias {
    /// @mockable
    public protocol SomeType {
        typealias Key = String
        var key: Key { get }
    }

    @Fixture enum expected {
        public class SomeTypeMock: SomeType {
            public init() { }
            public init(key: Key) {
                self._key = key
            }
            public typealias Key = String

            private var _key: Key!
            public var key: Key {
                get { return _key }
                set { _key = newValue }
            }
        }
    }
}

@Fixture enum patDefaultType {
    struct MyID: Identifiable {
        var id: Int
    }

    /// @mockable
    protocol Foo {
        associatedtype T
        associatedtype U = String
        associatedtype S: Identifiable = MyID where S.ID == Int
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            typealias T = Any
            typealias U = String
            typealias S = MyID
        }
    }
}

@Fixture enum patPartialOverride {
    /// @mockable(typealias: U = [Any])
    protocol Foo {
        associatedtype T
        associatedtype U: Collection where U.Element == T
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }
            typealias T = Any
            typealias U = [Any]
        }
    }
}
