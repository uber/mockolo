import SwiftMockGenCore


let simpleDuplicates = """
/// \(String.mockAnnotation)
public protocol SimpleDuplicate {
func remove(_ arg: Int)
func remove(_ arg: String)
func remove(_ arg: Float)

func push(state: Double, attachTransition: Int, detachTransition: Float?)
func push(state: Double, flag: Float, attachTransition: Int, detachTransition: Float?)
}
"""

let simpleDuplicatesMock = """
public class SimpleDuplicateMock: SimpleDuplicate {
    
    public init() {
        
    }
    
    var removeCallCount = 0
    public var removeHandler: ((Int) -> ())?
    public func remove(_ arg: Int)  {
        removeCallCount += 1
        if let removeHandler = removeHandler {
            return removeHandler(arg)
        }
        
    }
    var removeArgCallCount = 0
    public var removeArgHandler: ((String) -> ())?
    public func remove(_ arg: String)  {
        removeArgCallCount += 1
        if let removeArgHandler = removeArgHandler {
            return removeArgHandler(arg)
        }
        
    }
    var removeArg2CallCount = 0
    public var removeArg2Handler: ((Float) -> ())?
    public func remove(_ arg: Float)  {
        removeArg2CallCount += 1
        if let removeArg2Handler = removeArg2Handler {
            return removeArg2Handler(arg)
        }
        
    }
    var pushCallCount = 0
    public var pushHandler: ((Double, Int, Float?) -> ())?
    public func push(state: Double, attachTransition: Int, detachTransition: Float?)  {
        pushCallCount += 1
        if let pushHandler = pushHandler {
            return pushHandler(state, attachTransition, detachTransition)
        }
        
    }
    var pushStateCallCount = 0
    public var pushStateHandler: ((Double, Float, Int, Float?) -> ())?
    public func push(state: Double, flag: Float, attachTransition: Int, detachTransition: Float?)  {
        pushStateCallCount += 1
        if let pushStateHandler = pushStateHandler {
            return pushStateHandler(state, flag, attachTransition, detachTransition)
        }
        
    }
}
"""
