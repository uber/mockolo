import MockoloFramework

@Fixture enum inoutParams {
    /// @mockable
    public protocol Foo {
        func hash(into hasher: inout Hasher)
        func bar(lhs: inout String, rhs: inout Int)
    }

    @Fixture enum expected {
        public class FooMock: Foo {
            public init() { }


            public private(set) var hashCallCount = 0
            public var hashHandler: ((inout Hasher) -> ())?
            public func hash(into hasher: inout Hasher) {
                hashCallCount += 1
                if let hashHandler = hashHandler {
                    hashHandler(&hasher)
                }

            }

            public private(set) var barCallCount = 0
            public var barHandler: ((inout String, inout Int) -> ())?
            public func bar(lhs: inout String, rhs: inout Int) {
                barCallCount += 1
                if let barHandler = barHandler {
                    barHandler(&lhs, &rhs)
                }

            }
        }
    }
}

@Fixture enum subscripts {
    /// @mockable
    protocol SubscriptProtocol {
        associatedtype T
        associatedtype Value

        static subscript(key: Int) -> AnyObject? { get set }
        subscript(_ key: Int) -> AnyObject { get set }
        subscript(key: Int) -> AnyObject? { get set }
        subscript(index: String) -> CGImage? { get set }
        subscript(memoizeKey: Int) -> CGRect? { get set }
        subscript(position: Int) -> Any { get set }
        subscript(index: String.Index) -> Double { get set }
        subscript(safe index: String.Index) -> Double? { get set }
        subscript(range: Range<Int>) -> String { get set }
        subscript(path: String) -> ((Double) -> Float)? { get set }
        subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Double, T>) -> T { get set }
        subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<String, T>) -> T { get set }
        subscript<T>(dynamicMember keyPath: WritableKeyPath<T, Value>) -> Value { get set }
        subscript<T: ExpressibleByIntegerLiteral>(_ parameter: T) -> T { get set }
        subscript<Value>(keyPath: ReferenceWritableKeyPath<T, Value>) -> Array<Value> { get set }
        subscript<Value>(keyPath: ReferenceWritableKeyPath<T, Value>, on schedulerType: T) -> Array<Value> { get set }
    }

    /// @mockable
    public protocol KeyValueSubscripting {
        associatedtype Key
        associatedtype Value

        /// Accesses the value associated with the given key for reading and writing.
        subscript(key: Key) -> Value? { get set }

        /// Accesses the value with the given key. If the receiver doesn’t contain the given key, accesses the provided default value as if the key and default value existed in the receiver.
        subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value { get set }
    }

    @Fixture enum expected {
        class SubscriptProtocolMock: SubscriptProtocol {
            init() { }

            typealias T = Any
            typealias Value = Any

            static private(set) var subscriptCallCount = 0
            static var subscriptHandler: ((Int) -> AnyObject?)?
            static private(set) var subscriptSetCallCount = 0
            static var subscriptSetHandler: ((Int, AnyObject?) -> ())?
            static subscript(key: Int) -> AnyObject? {
                get {
                subscriptCallCount += 1
                if let subscriptHandler = subscriptHandler {
                    return subscriptHandler(key)
                }
                return nil
                }
                set {
                subscriptSetCallCount += 1
                subscriptSetHandler?(key, newValue)
                }
            }

            private(set) var subscriptKeyCallCount = 0
            var subscriptKeyHandler: ((Int) -> AnyObject)?
            private(set) var subscriptKeySetCallCount = 0
            var subscriptKeySetHandler: ((Int, AnyObject) -> ())?
            subscript(_ key: Int) -> AnyObject {
                get {
                subscriptKeyCallCount += 1
                if let subscriptKeyHandler = subscriptKeyHandler {
                    return subscriptKeyHandler(key)
                }
                fatalError("subscriptKeyHandler returns can't have a default value thus its handler must be set")
                }
                set {
                subscriptKeySetCallCount += 1
                subscriptKeySetHandler?(key, newValue)
                }
            }

            private(set) var subscriptKeyIntCallCount = 0
            var subscriptKeyIntHandler: ((Int) -> AnyObject?)?
            private(set) var subscriptKeyIntSetCallCount = 0
            var subscriptKeyIntSetHandler: ((Int, AnyObject?) -> ())?
            subscript(key: Int) -> AnyObject? {
                get {
                subscriptKeyIntCallCount += 1
                if let subscriptKeyIntHandler = subscriptKeyIntHandler {
                    return subscriptKeyIntHandler(key)
                }
                return nil
                }
                set {
                subscriptKeyIntSetCallCount += 1
                subscriptKeyIntSetHandler?(key, newValue)
                }
            }

            private(set) var subscriptIndexCallCount = 0
            var subscriptIndexHandler: ((String) -> CGImage?)?
            private(set) var subscriptIndexSetCallCount = 0
            var subscriptIndexSetHandler: ((String, CGImage?) -> ())?
            subscript(index: String) -> CGImage? {
                get {
                subscriptIndexCallCount += 1
                if let subscriptIndexHandler = subscriptIndexHandler {
                    return subscriptIndexHandler(index)
                }
                return nil
                }
                set {
                subscriptIndexSetCallCount += 1
                subscriptIndexSetHandler?(index, newValue)
                }
            }

            private(set) var subscriptMemoizeKeyCallCount = 0
            var subscriptMemoizeKeyHandler: ((Int) -> CGRect?)?
            private(set) var subscriptMemoizeKeySetCallCount = 0
            var subscriptMemoizeKeySetHandler: ((Int, CGRect?) -> ())?
            subscript(memoizeKey: Int) -> CGRect? {
                get {
                subscriptMemoizeKeyCallCount += 1
                if let subscriptMemoizeKeyHandler = subscriptMemoizeKeyHandler {
                    return subscriptMemoizeKeyHandler(memoizeKey)
                }
                return nil
                }
                set {
                subscriptMemoizeKeySetCallCount += 1
                subscriptMemoizeKeySetHandler?(memoizeKey, newValue)
                }
            }

            private(set) var subscriptPositionCallCount = 0
            var subscriptPositionHandler: ((Int) -> Any)?
            private(set) var subscriptPositionSetCallCount = 0
            var subscriptPositionSetHandler: ((Int, Any) -> ())?
            subscript(position: Int) -> Any {
                get {
                subscriptPositionCallCount += 1
                if let subscriptPositionHandler = subscriptPositionHandler {
                    return subscriptPositionHandler(position)
                }
                fatalError("subscriptPositionHandler returns can't have a default value thus its handler must be set")
                }
                set {
                subscriptPositionSetCallCount += 1
                subscriptPositionSetHandler?(position, newValue)
                }
            }

            private(set) var subscriptIndexStringIndexCallCount = 0
            var subscriptIndexStringIndexHandler: ((String.Index) -> Double)?
            private(set) var subscriptIndexStringIndexSetCallCount = 0
            var subscriptIndexStringIndexSetHandler: ((String.Index, Double) -> ())?
            subscript(index: String.Index) -> Double {
                get {
                subscriptIndexStringIndexCallCount += 1
                if let subscriptIndexStringIndexHandler = subscriptIndexStringIndexHandler {
                    return subscriptIndexStringIndexHandler(index)
                }
                return 0.0
                }
                set {
                subscriptIndexStringIndexSetCallCount += 1
                subscriptIndexStringIndexSetHandler?(index, newValue)
                }
            }

            private(set) var subscriptSafeCallCount = 0
            var subscriptSafeHandler: ((String.Index) -> Double?)?
            private(set) var subscriptSafeSetCallCount = 0
            var subscriptSafeSetHandler: ((String.Index, Double?) -> ())?
            subscript(safe index: String.Index) -> Double? {
                get {
                subscriptSafeCallCount += 1
                if let subscriptSafeHandler = subscriptSafeHandler {
                    return subscriptSafeHandler(index)
                }
                return nil
                }
                set {
                subscriptSafeSetCallCount += 1
                subscriptSafeSetHandler?(index, newValue)
                }
            }

            private(set) var subscriptRangeCallCount = 0
            var subscriptRangeHandler: ((Range<Int>) -> String)?
            private(set) var subscriptRangeSetCallCount = 0
            var subscriptRangeSetHandler: ((Range<Int>, String) -> ())?
            subscript(range: Range<Int>) -> String {
                get {
                subscriptRangeCallCount += 1
                if let subscriptRangeHandler = subscriptRangeHandler {
                    return subscriptRangeHandler(range)
                }
                return ""
                }
                set {
                subscriptRangeSetCallCount += 1
                subscriptRangeSetHandler?(range, newValue)
                }
            }

            private(set) var subscriptPathCallCount = 0
            var subscriptPathHandler: ((String) -> ((Double) -> Float)?)?
            private(set) var subscriptPathSetCallCount = 0
            var subscriptPathSetHandler: ((String, ((Double) -> Float)?) -> ())?
            subscript(path: String) -> ((Double) -> Float)? {
                get {
                subscriptPathCallCount += 1
                if let subscriptPathHandler = subscriptPathHandler {
                    return subscriptPathHandler(path)
                }
                return nil
                }
                set {
                subscriptPathSetCallCount += 1
                subscriptPathSetHandler?(path, newValue)
                }
            }

            private(set) var subscriptDynamicMemberCallCount = 0
            var subscriptDynamicMemberHandler: ((Any) -> Any)?
            private(set) var subscriptDynamicMemberSetCallCount = 0
            var subscriptDynamicMemberSetHandler: ((Any, Any) -> ())?
            subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Double, T>) -> T {
                get {
                subscriptDynamicMemberCallCount += 1
                if let subscriptDynamicMemberHandler = subscriptDynamicMemberHandler {
                    return subscriptDynamicMemberHandler(keyPath) as! T
                }
                fatalError("subscriptDynamicMemberHandler returns can't have a default value thus its handler must be set")
                }
                set {
                subscriptDynamicMemberSetCallCount += 1
                subscriptDynamicMemberSetHandler?(keyPath, newValue)
                }
            }

            private(set) var subscriptDynamicMemberTCallCount = 0
            var subscriptDynamicMemberTHandler: ((Any) -> Any)?
            private(set) var subscriptDynamicMemberTSetCallCount = 0
            var subscriptDynamicMemberTSetHandler: ((Any, Any) -> ())?
            subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<String, T>) -> T {
                get {
                subscriptDynamicMemberTCallCount += 1
                if let subscriptDynamicMemberTHandler = subscriptDynamicMemberTHandler {
                    return subscriptDynamicMemberTHandler(keyPath) as! T
                }
                fatalError("subscriptDynamicMemberTHandler returns can't have a default value thus its handler must be set")
                }
                set {
                subscriptDynamicMemberTSetCallCount += 1
                subscriptDynamicMemberTSetHandler?(keyPath, newValue)
                }
            }

            private(set) var subscriptDynamicMemberTWritableKeyPathTValueCallCount = 0
            var subscriptDynamicMemberTWritableKeyPathTValueHandler: ((Any) -> Value)?
            private(set) var subscriptDynamicMemberTWritableKeyPathTValueSetCallCount = 0
            var subscriptDynamicMemberTWritableKeyPathTValueSetHandler: ((Any, Value) -> ())?
            subscript<T>(dynamicMember keyPath: WritableKeyPath<T, Value>) -> Value {
                get {
                subscriptDynamicMemberTWritableKeyPathTValueCallCount += 1
                if let subscriptDynamicMemberTWritableKeyPathTValueHandler = subscriptDynamicMemberTWritableKeyPathTValueHandler {
                    return subscriptDynamicMemberTWritableKeyPathTValueHandler(keyPath)
                }
                fatalError("subscriptDynamicMemberTWritableKeyPathTValueHandler returns can't have a default value thus its handler must be set")
                }
                set {
                subscriptDynamicMemberTWritableKeyPathTValueSetCallCount += 1
                subscriptDynamicMemberTWritableKeyPathTValueSetHandler?(keyPath, newValue)
                }
            }

            private(set) var subscriptParameterCallCount = 0
            var subscriptParameterHandler: ((Any) -> Any)?
            private(set) var subscriptParameterSetCallCount = 0
            var subscriptParameterSetHandler: ((Any, Any) -> ())?
            subscript<T: ExpressibleByIntegerLiteral>(_ parameter: T) -> T {
                get {
                subscriptParameterCallCount += 1
                if let subscriptParameterHandler = subscriptParameterHandler {
                    return subscriptParameterHandler(parameter) as! T
                }
                fatalError("subscriptParameterHandler returns can't have a default value thus its handler must be set")
                }
                set {
                subscriptParameterSetCallCount += 1
                subscriptParameterSetHandler?(parameter, newValue)
                }
            }

            private(set) var subscriptKeyPathCallCount = 0
            var subscriptKeyPathHandler: ((Any) -> Any)?
            private(set) var subscriptKeyPathSetCallCount = 0
            var subscriptKeyPathSetHandler: ((Any, Any) -> ())?
            subscript<Value>(keyPath: ReferenceWritableKeyPath<T, Value>) -> Array<Value> {
                get {
                subscriptKeyPathCallCount += 1
                if let subscriptKeyPathHandler = subscriptKeyPathHandler {
                    return subscriptKeyPathHandler(keyPath) as! Array<Value>
                }
                return Array<Value>()
                }
                set {
                subscriptKeyPathSetCallCount += 1
                subscriptKeyPathSetHandler?(keyPath, newValue)
                }
            }

            private(set) var subscriptKeyPathOnCallCount = 0
            var subscriptKeyPathOnHandler: ((Any, T) -> Any)?
            private(set) var subscriptKeyPathOnSetCallCount = 0
            var subscriptKeyPathOnSetHandler: ((Any, T, Any) -> ())?
            subscript<Value>(keyPath: ReferenceWritableKeyPath<T, Value>, on schedulerType: T) -> Array<Value> {
                get {
                subscriptKeyPathOnCallCount += 1
                if let subscriptKeyPathOnHandler = subscriptKeyPathOnHandler {
                    return subscriptKeyPathOnHandler(keyPath, schedulerType) as! Array<Value>
                }
                return Array<Value>()
                }
                set {
                subscriptKeyPathOnSetCallCount += 1
                subscriptKeyPathOnSetHandler?(keyPath, schedulerType, newValue)
                }
            }
        }

        public class KeyValueSubscriptingMock: KeyValueSubscripting {
            public init() { }

            public typealias Key = Any
            public typealias Value = Any

            public private(set) var subscriptCallCount = 0
            public var subscriptHandler: ((Key) -> Value?)?
            public private(set) var subscriptSetCallCount = 0
            public var subscriptSetHandler: ((Key, Value?) -> ())?
            public subscript(key: Key) -> Value? {
                get {
                subscriptCallCount += 1
                if let subscriptHandler = subscriptHandler {
                    return subscriptHandler(key)
                }
                return nil
                }
                set {
                subscriptSetCallCount += 1
                subscriptSetHandler?(key, newValue)
                }
            }

            public private(set) var subscriptKeyCallCount = 0
            public var subscriptKeyHandler: ((Key, @autoclosure () -> Value) -> Value)?
            public private(set) var subscriptKeySetCallCount = 0
            public var subscriptKeySetHandler: ((Key, @autoclosure () -> Value, Value) -> ())?
            public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
                get {
                subscriptKeyCallCount += 1
                if let subscriptKeyHandler = subscriptKeyHandler {
                    return subscriptKeyHandler(key, defaultValue())
                }
                fatalError("subscriptKeyHandler returns can't have a default value thus its handler must be set")
                }
                set {
                subscriptKeySetCallCount += 1
                subscriptKeySetHandler?(key, defaultValue(), newValue)
                }
            }
        }
    }
}

@Fixture enum getOnlySubscripts {
    /// @mockable
    protocol GetOnlySubscriptProtocol {
        subscript(key: Int) -> String { get }
        subscript(index: String) -> Int? { get }
    }

    @Fixture enum expected {
        class GetOnlySubscriptProtocolMock: GetOnlySubscriptProtocol {
            init() { }


            private(set) var subscriptCallCount = 0
            var subscriptHandler: ((Int) -> String)?
            subscript(key: Int) -> String {
                get {
                subscriptCallCount += 1
                if let subscriptHandler = subscriptHandler {
                    return subscriptHandler(key)
                }
                return ""
                }
            }

            private(set) var subscriptIndexCallCount = 0
            var subscriptIndexHandler: ((String) -> Int?)?
            subscript(index: String) -> Int? {
                get {
                subscriptIndexCallCount += 1
                if let subscriptIndexHandler = subscriptIndexHandler {
                    return subscriptIndexHandler(index)
                }
                return nil
                }
            }
        }
    }
}

@Fixture enum allowSetCallCountSubscripts {
    /// @mockable
    protocol AllowSetCallCountSubscriptProtocol {
        subscript(key: Int) -> String { get set }
    }

    @Fixture enum expected {
        class AllowSetCallCountSubscriptProtocolMock: AllowSetCallCountSubscriptProtocol {
            init() { }


            var subscriptCallCount = 0
            var subscriptHandler: ((Int) -> String)?
            var subscriptSetCallCount = 0
            var subscriptSetHandler: ((Int, String) -> ())?
            subscript(key: Int) -> String {
                get {
                subscriptCallCount += 1
                if let subscriptHandler = subscriptHandler {
                    return subscriptHandler(key)
                }
                return ""
                }
                set {
                subscriptSetCallCount += 1
                subscriptSetHandler?(key, newValue)
                }
            }
        }
    }
}

@Fixture enum variadicFunc {
    /// @mockable
    protocol NonSimpleFuncs {
        func bar(_ arg: String, x: Int..., y: [Double]) -> Float?
    }

    @Fixture enum expected {
        class NonSimpleFuncsMock: NonSimpleFuncs {
            init() { }


            private(set) var barCallCount = 0
            var barHandler: ((String, [Int], [Double]) -> Float?)?
            func bar(_ arg: String, x: Int..., y: [Double]) -> Float? {
                barCallCount += 1
                if let barHandler = barHandler {
                    return barHandler(arg, x, y)
                }
                return nil
            }
        }
    }
}

@Fixture enum autoclosureArgFunc {
    /// @mockable
    protocol NonSimpleFuncs {
        func pass<T>(handler: @autoclosure () -> Int) throws -> T
    }

    @Fixture enum expected {
        class NonSimpleFuncsMock: NonSimpleFuncs {
            init() { }


            private(set) var passCallCount = 0
            var passHandler: ((@autoclosure () -> Int) throws -> Any)?
            func pass<T>(handler: @autoclosure () -> Int) throws -> T {
                passCallCount += 1
                if let passHandler = passHandler {
                    return try passHandler(handler()) as! T
                }
                fatalError("passHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}

#if compiler(>=6.0)
@Fixture enum rethrowsFunc {
    /// @mockable
    protocol RethrowsFuncs {
        func cat(closure: () throws -> Void) rethrows
    }

    @Fixture enum expected {
        class RethrowsFuncsMock: RethrowsFuncs {
            init() { }


            private(set) var catCallCount = 0
            var catHandler: ((() throws(any Error) -> Any) throws(any Error) -> Void)?
            func cat<Failure: Error>(closure: () throws(Failure) -> Void) throws(Failure) {
                catCallCount += 1
                if let catHandler = catHandler {
                    do {
                        try catHandler(closure)
                    } catch {
                        throw error as! Failure
                    }
                }
                fatalError("catHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}
#endif

@Fixture enum forArgClosureFunc {
    /// @mockable
    protocol NonSimpleFuncs {
        func max(for: Int) -> (() -> Void)?
        func maxDo(do: Int) -> (() -> Void)?
        func maxIn(in: Int) -> (() -> Void)?
        func maxSwitch(for switch: Int) -> (() -> Void)?
        func maxExtension(extension: Int) -> (() -> Void)?
    }

    @Fixture enum expected {
        class NonSimpleFuncsMock: NonSimpleFuncs {
            init() { }


            private(set) var maxCallCount = 0
            var maxHandler: ((Int) -> (() -> Void)?)?
            func max(for: Int) -> (() -> Void)? {
                maxCallCount += 1
                if let maxHandler = maxHandler {
                    return maxHandler(`for`)
                }
                return nil
            }

            private(set) var maxDoCallCount = 0
            var maxDoHandler: ((Int) -> (() -> Void)?)?
            func maxDo(do: Int) -> (() -> Void)? {
                maxDoCallCount += 1
                if let maxDoHandler = maxDoHandler {
                    return maxDoHandler(`do`)
                }
                return nil
            }

            private(set) var maxInCallCount = 0
            var maxInHandler: ((Int) -> (() -> Void)?)?
            func maxIn(in: Int) -> (() -> Void)? {
                maxInCallCount += 1
                if let maxInHandler = maxInHandler {
                    return maxInHandler(`in`)
                }
                return nil
            }

            private(set) var maxSwitchCallCount = 0
            var maxSwitchHandler: ((Int) -> (() -> Void)?)?
            func maxSwitch(for switch: Int) -> (() -> Void)? {
                maxSwitchCallCount += 1
                if let maxSwitchHandler = maxSwitchHandler {
                    return maxSwitchHandler(`switch`)
                }
                return nil
            }

            private(set) var maxExtensionCallCount = 0
            var maxExtensionHandler: ((Int) -> (() -> Void)?)?
            func maxExtension(extension: Int) -> (() -> Void)? {
                maxExtensionCallCount += 1
                if let maxExtensionHandler = maxExtensionHandler {
                    return maxExtensionHandler(`extension`)
                }
                return nil
            }
        }
    }
}

@Fixture enum returnSelfFunc {
    /// @mockable
    protocol NonSimpleFuncs {
        @discardableResult
        func returnSelf() -> Self
    }

    @Fixture enum expected {
        class NonSimpleFuncsMock: NonSimpleFuncs {
            init() { }

            
            private(set) var returnSelfCallCount = 0
            var returnSelfHandler: (() -> NonSimpleFuncsMock)?
            func returnSelf() -> Self {
                returnSelfCallCount += 1
                if let returnSelfHandler = returnSelfHandler {
                    return returnSelfHandler() as! Self
                }
                fatalError("returnSelfHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}

