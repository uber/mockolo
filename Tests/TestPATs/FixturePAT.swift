import MockoloFramework

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
    /// @mockable(typealias: T = Any; U = Hashable & Codable; R = (String, Int); S = AnyObject)
    protocol Foo {
        associatedtype T
        associatedtype U
        associatedtype R
        associatedtype S
    }

    @Fixture enum expected {
        class FooMock: Foo {
            init() { }

            typealias T = Any
            typealias U = Hashable & Codable
            typealias R = (String, Int)
            typealias S = AnyObject
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
        associatedtype S: Identifiable, Sendable = MyID where S.ID == Int
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

@Fixture enum patWithConditions {
    /// @mockable
    public protocol Foo {
        associatedtype T: StringProtocol
    }

    /// @mockable(typealias: T = String)
    public protocol Bar {
        associatedtype T: StringProtocol
    }

    /// @mockable
    public protocol Baz {
        associatedtype T where T: StringProtocol
    }

    @Fixture enum expected {
        public class FooMock<T: StringProtocol>: Foo {
            public init() { }
        }

        public class BarMock: Bar {
            public init() { }
            public typealias T = String
        }

        public class BazMock<T>: Baz where T: StringProtocol {
            public init() { }
        }
    }
}

@Fixture enum patNameCollision {
    protocol Foo {
        associatedtype T
    }

    protocol Bar {
        associatedtype T: StringProtocol
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

    /// @mockable
    protocol Cat: Bar where T: Identifiable & Sendable, T.ID == String {
    }

    @Fixture enum expected {
        class BazMock<T: StringProtocol>: Baz {
            init() { }
        }

        class DogMock<T>: Dog where T: StringProtocol, T: Identifiable & Sendable, T.ID == String {
            init() {}
        }

        class CatMock<T>: Cat where T: StringProtocol, T: Identifiable & Sendable, T.ID == String {
            init() {}
        }
    }
}
