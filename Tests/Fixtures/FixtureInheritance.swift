import SwiftMockGenCore

let funcsInheritance = """
import Foundation

/// \(String.mockAnnotation)
public protocol InheritedFuncs: Parent {
    
    func navigateBack(_ transitionStyle: TransitionStyle) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?)
    func navigateBack(_ toState: RouterState_DEPRECATED?, transitionStyle: TransitionStyle) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?)
}
    
/// \(String.mockAnnotation)
public protocol Parent: class {
    
    func navigateBack() -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?)
    func navigateBack(_ toState: RouterState_DEPRECATED?) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?)
}
    
"""
    
let funcsInheritanceMock = """
import Foundation

public class InheritedFuncsMock: InheritedFuncs {
    public init() {
        
    }
    
    var navigateBackTransitionStyleCallCount = 0
    var navigateBackTransitionStyleHandler: ((TransitionStyle) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?))?
    public func navigateBack(_ transitionStyle: TransitionStyle) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?) {
        navigateBackTransitionStyleCallCount += 1
        if let navigateBackTransitionStyleHandler = navigateBackTransitionStyleHandler {
            return navigateBackTransitionStyleHandler(transitionStyle)
        }
        return (nil, nil, nil, nil)
    }
    var navigateBackToStateTransitionStyleCallCount = 0
    var navigateBackToStateTransitionStyleHandler: ((RouterState_DEPRECATED?, TransitionStyle) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?))?
    public func navigateBack(_ toState: RouterState_DEPRECATED?, transitionStyle: TransitionStyle) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?) {
        navigateBackToStateTransitionStyleCallCount += 1
        if let navigateBackToStateTransitionStyleHandler = navigateBackToStateTransitionStyleHandler {
            return navigateBackToStateTransitionStyleHandler(toState, transitionStyle)
        }
        return (nil, nil, nil, nil)
    }
    var navigateBackCallCount = 0
    var navigateBackHandler: (() -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?))?
    public func navigateBack() -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?) {
        navigateBackCallCount += 1
        if let navigateBackHandler = navigateBackHandler {
            return navigateBackHandler()
        }
        return (nil, nil, nil, nil)
    }
    var navigateBackToStateCallCount = 0
    var navigateBackToStateHandler: ((RouterState_DEPRECATED?) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?))?
    public func navigateBack(_ toState: RouterState_DEPRECATED?) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?) {
        navigateBackToStateCallCount += 1
        if let navigateBackToStateHandler = navigateBackToStateHandler {
            return navigateBackToStateHandler(toState)
        }
        return (nil, nil, nil, nil)
    }
}

public class ParentMock: Parent {
    public init() {
        
    }
    
    var navigateBackCallCount = 0
    var navigateBackHandler: (() -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?))?
    public func navigateBack() -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?) {
        navigateBackCallCount += 1
        if let navigateBackHandler = navigateBackHandler {
            return navigateBackHandler()
        }
        return (nil, nil, nil, nil)
    }
    var navigateBackToStateCallCount = 0
    var navigateBackToStateHandler: ((RouterState_DEPRECATED?) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?))?
    public func navigateBack(_ toState: RouterState_DEPRECATED?) -> (currentState: RouterState_DEPRECATED?, currentStateRouter: Routing?, previousStateRouter: Routing?, detachedTransientRouter: Routing?) {
        navigateBackToStateCallCount += 1
        if let navigateBackToStateHandler = navigateBackToStateHandler {
            return navigateBackToStateHandler(toState)
        }
        return (nil, nil, nil, nil)
    }
}

"""
    

let duplicateFuncsInheritance =  """
import Foundation

    /// \(String.mockAnnotation)
    public protocol StateRouterNavigatable_DEPRECATED: class {
    
    @discardableResult
    func detachTransientState(_ state: RouterState_DEPRECATED) -> (topRouter: Routing?, detachedTransientRouter: Routing?)
    }
    
    /// \(String.mockAnnotation)
    public protocol ViewableStateRouterNavigatable_DEPRECATED: StateRouterNavigatable_DEPRECATED {
    @discardableResult
    func detachTransientState(_ state: RouterState_DEPRECATED, transitionStyle: TransitionStyle) -> (topRouter: Routing?, detachedTransientRouter: Routing?)
    }
"""
    
let duplicateFuncsInheritanceMock = """
import Foundation

public class StateRouterNavigatable_DEPRECATEDMock: StateRouterNavigatable_DEPRECATED {
    public init() {
        
    }
    
    var detachTransientStateCallCount = 0
    var detachTransientStateHandler: ((RouterState_DEPRECATED) -> (topRouter: Routing?, detachedTransientRouter: Routing?))?
    public func detachTransientState(_ state: RouterState_DEPRECATED) -> (topRouter: Routing?, detachedTransientRouter: Routing?) {
        detachTransientStateCallCount += 1
        if let detachTransientStateHandler = detachTransientStateHandler {
            return detachTransientStateHandler(state)
        }
        return (nil, nil)
    }
}

public class ViewableStateRouterNavigatable_DEPRECATEDMock: ViewableStateRouterNavigatable_DEPRECATED {
    public init() {
        
    }
    
    var detachTransientStateCallCount = 0
    var detachTransientStateHandler: ((RouterState_DEPRECATED) -> (topRouter: Routing?, detachedTransientRouter: Routing?))?
    public func detachTransientState(_ state: RouterState_DEPRECATED) -> (topRouter: Routing?, detachedTransientRouter: Routing?) {
        detachTransientStateCallCount += 1
        if let detachTransientStateHandler = detachTransientStateHandler {
            return detachTransientStateHandler(state)
        }
        return (nil, nil)
    }
    var detachTransientStateTransitionStyleCallCount = 0
    var detachTransientStateTransitionStyleHandler: ((RouterState_DEPRECATED, TransitionStyle) -> (topRouter: Routing?, detachedTransientRouter: Routing?))?
    public func detachTransientState(_ state: RouterState_DEPRECATED, transitionStyle: TransitionStyle) -> (topRouter: Routing?, detachedTransientRouter: Routing?) {
        detachTransientStateTransitionStyleCallCount += 1
        if let detachTransientStateTransitionStyleHandler = detachTransientStateTransitionStyleHandler {
            return detachTransientStateTransitionStyleHandler(state, transitionStyle)
        }
        return (nil, nil)
    }
}
"""
