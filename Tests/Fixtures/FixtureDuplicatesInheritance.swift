import SwiftMockGenCore

let duplicateSigInheritance =  """
import Foundation

/// \(String.mockAnnotation)
public protocol Parent: AnyObject {

@discardableResult
func updateState(_ state: Int) -> (result: Double?, status: Bool?)
}

/// \(String.mockAnnotation)
public protocol Child: Parent {
@discardableResult
func updateState(_ state: Int, style: SomeStyle) -> (result: Double?, status: Bool?)
}
"""

let duplicateSigInheritanceMock = """
import Foundation

public class ParentMock: Parent {
    
    public init() {
        
    }
    
    var updateStateCallCount = 0
    var updateStateHandler: ((Int) -> (result: Double?, status: Bool?))?
    public func updateState(_ state: Int) -> (result: Double?, status: Bool?) {
        updateStateCallCount += 1
        if let updateStateHandler = updateStateHandler {
            return updateStateHandler(state)
        }
        return (nil, nil)
    }
}

public class ChildMock: Child {
    
    public init() {
        
    }
    
    var updateStateResultDoubleStatusBoolCallCount = 0
    var updateStateResultDoubleStatusBoolHandler: ((Int) -> (result: Double?, status: Bool?))?
    public func updateState(_ state: Int) -> (result: Double?, status: Bool?) {
        updateStateResultDoubleStatusBoolCallCount += 1
        if let updateStateResultDoubleStatusBoolHandler = updateStateResultDoubleStatusBoolHandler {
            return updateStateResultDoubleStatusBoolHandler(state)
        }
        return (nil, nil)
    }
    var updateStateCallCount = 0
    var updateStateHandler: ((Int, SomeStyle) -> (result: Double?, status: Bool?))?
    public func updateState(_ state: Int, style: SomeStyle) -> (result: Double?, status: Bool?) {
        updateStateCallCount += 1
        if let updateStateHandler = updateStateHandler {
            return updateStateHandler(state, style)
        }
        return (nil, nil)
    }
}
"""
