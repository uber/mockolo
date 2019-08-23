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

let nonSimpleVarsMock =
"""
import Foundation

@available(iOS 10.0, *)
public class NonSimpleVarsMock: NonSimpleVars {
    
    private var _doneInit = false
    public init() { _doneInit = true }
    public init(dict: Dictionary<String, Int> = Dictionary<String, Int>()) {
        self.dict = dict
        _doneInit = true
    }
    
    public var dictSetCallCount = 0
    var underlyingDict: Dictionary<String, Int> = Dictionary<String, Int>()
    public var dict: Dictionary<String, Int> {
        get { return underlyingDict }
        set {
            underlyingDict = newValue
            if _doneInit { dictSetCallCount += 1 }
        }
    }
    
    public var closureVarSetCallCount = 0
    var underlyingClosureVar: ((_ arg: String) -> Void)? = nil
    public var closureVar: ((_ arg: String) -> Void)? {
        get { return underlyingClosureVar }
        set {
            underlyingClosureVar = newValue
            if _doneInit { closureVarSetCallCount += 1 }
        }
    }
    
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
    var underlyingHasDot: ModuleX.SomeType? = nil
    public var hasDot: ModuleX.SomeType? {
        get { return underlyingHasDot }
        set {
            underlyingHasDot = newValue
            if _doneInit { hasDotSetCallCount += 1 }
        }
    }
}

"""
