import MockoloFramework

let nonSimpleVars = """
import Foundation

/// \(String.mockAnnotation)
@objc
public protocol NonSimpleVars {
    @available(iOS 10.0, *)
    var dict: Dictionary<String, Int> { get set }
    var closureVar: ((_ arg: String) -> Void)?
    var voidHandler: (() -> ()) { get }
    var hasDot: ModuleX.SomeType?
}
"""

let nonSimpleVarsMock = """
import Foundation

@available(iOS 10.0, *)
public class NonSimpleVarsMock: NonSimpleVars {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(dict: Dictionary<String, Int> = Dictionary<String, Int>(), voidHandler: @escaping (() -> ()), hasDot: ModuleX.SomeType? = nil) {
        self.dict = dict
        self.voidHandler = voidHandler
        self.hasDot = hasDot
        _doneInit = true
    }
    public var dictSetCallCount = 0
    public var dict: Dictionary<String, Int> = Dictionary<String, Int>() { didSet { dictSetCallCount += 1 } }
    public var closureVarSetCallCount = 0
    public var closureVar: ((_ arg: String) -> Void)? = nil { didSet { closureVarSetCallCount += 1 } }
    public var voidHandlerSetCallCount = 0
    var underlyingVoidHandler: ((() -> ()))!
    public var voidHandler: (() -> ()) {
        get { return underlyingVoidHandler }
        set {
            underlyingVoidHandler = newValue
            if _doneInit { voidHandlerSetCallCount += 1 }
        }
    }
    public var hasDotSetCallCount = 0
    public var hasDot: ModuleX.SomeType? = nil { didSet { hasDotSetCallCount += 1 } }
}

"""
