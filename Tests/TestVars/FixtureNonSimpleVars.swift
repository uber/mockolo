import MockoloFramework

let nonSimpleVars = """
import Foundation

/// \(String.mockAnnotation)
@objc
public protocol NonSimpleVars {
    @available(iOS 10.0, *)
    var dict: Dictionary<String, Int> { get set }

    var closureVar: ((_ arg: String) -> Void)? { get }
    var voidHandler: (() -> ()) { get }
    var hasDot: ModuleX.SomeType? { get }
    static var someVal: String { get }
}
"""

let nonSimpleVarsMock = """
import Foundation

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
    public private(set) var closureVarSetCallCount = 0
    public var closureVar: ((_ arg: String) -> Void)? = nil { didSet { closureVarSetCallCount += 1 } }
    public private(set) var voidHandlerSetCallCount = 0
    private var _voidHandler: ((() -> ()))!  { didSet { voidHandlerSetCallCount += 1 } }
    public var voidHandler: (() -> ()) {
        get { return _voidHandler }
        set { _voidHandler = newValue }
    }
    public private(set) var hasDotSetCallCount = 0
    public var hasDot: ModuleX.SomeType? = nil { didSet { hasDotSetCallCount += 1 } }

    public static private(set) var someValSetCallCount = 0
    static private var _someVal: String = "" { didSet { someValSetCallCount += 1 } }
    public static var someVal: String {
        get { return _someVal }
        set { _someVal = newValue }
    }
}

"""
