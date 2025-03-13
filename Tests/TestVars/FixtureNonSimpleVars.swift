import MockoloFramework
import Foundation

@Fixture enum nonSimpleVars {
    enum ModuleX {
        class SomeType: NSObject {}
    }

    /// @mockable
    @objc
    public protocol NonSimpleVars {
        @available(iOS 10.0, *)
        var dict: Dictionary<String, Int> { get set }

        var closureVar: ((_ arg: String) -> Void)? { get }
        var voidHandler: (() -> ()) { get }
        var hasDot: ModuleX.SomeType? { get }
        static var someVal: String { get }
        static var someVal2: String { get set }
    }

    @Fixture enum expected {
        @available(iOS 10.0, *)
        public class NonSimpleVarsMock: NonSimpleVars {
            public init() { }
            public init(dict: Dictionary<String, Int> = Dictionary<String, Int>(), voidHandler: @escaping (() -> ()), hasDot: ModuleX.SomeType? = nil) {
                self.dict = dict
                self._voidHandler = voidHandler
                self.hasDot = hasDot
            }
            public private(set) var dictSetCallCount = 0
            public var dict: Dictionary<String, Int> = Dictionary<String, Int>() { didSet { dictSetCallCount += 1 } }

            public var closureVar: ((_ arg: String) -> Void)? = nil

            private var _voidHandler: ((() -> ()))!
            public var voidHandler: (() -> ()) {
                get { return _voidHandler }
                set { _voidHandler = newValue }
            }

            public var hasDot: ModuleX.SomeType? = nil


            public static var someVal: String = ""

            public static private(set) var someVal2SetCallCount = 0
            public static var someVal2: String = "" { didSet { someVal2SetCallCount += 1 } }
        }
    }
}
