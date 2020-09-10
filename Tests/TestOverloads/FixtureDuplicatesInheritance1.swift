import MockoloFramework

let overload8 =  """
import Foundation

/// \(String.mockAnnotation)
public protocol Parent: AnyObject {

@discardableResult
func updateState(_ state: Int) -> (result: Double?, status: Bool)
}

/// \(String.mockAnnotation)
public protocol Child: Parent {
@discardableResult
func updateState(_ state: Int, style: SomeStyle) -> (result: Double?, status: Bool)
}
"""

let overloadMock8 =
"""

import Foundation


public class ParentMock: Parent {
    public init() { }


    public private(set) var updateStateCallCount = 0
    public var updateStateHandler: ((Int) -> (result: Double?, status: Bool))?
    public func updateState(_ state: Int) -> (result: Double?, status: Bool) {
        updateStateCallCount += 1
        if let updateStateHandler = updateStateHandler {
            return updateStateHandler(state)
        }
        return (nil, false)
    }
}

public class ChildMock: Child {
    public init() { }


    public private(set) var updateStateIntCallCount = 0
    public var updateStateIntHandler: ((Int) -> (result: Double?, status: Bool))?
    public func updateState(_ state: Int) -> (result: Double?, status: Bool) {
        updateStateIntCallCount += 1
        if let updateStateIntHandler = updateStateIntHandler {
            return updateStateIntHandler(state)
        }
        return (nil, false)
    }

    public private(set) var updateStateCallCount = 0
    public var updateStateHandler: ((Int, SomeStyle) -> (result: Double?, status: Bool))?
    public func updateState(_ state: Int, style: SomeStyle) -> (result: Double?, status: Bool) {
        updateStateCallCount += 1
        if let updateStateHandler = updateStateHandler {
            return updateStateHandler(state, style)
        }
        return (nil, false)
    }
}

"""
