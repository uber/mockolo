import SwiftMockGenCore


let simpleDuplicates = """
/// \(String.mockAnnotation)
public protocol SimpleDuplicate {
func push(state: Double,
attachTransition: Int,
detachTransition: Float?)

func push(state: Double,
flag: Float,
attachTransition: Int,
detachTransition: Float?)
}
"""

let simpleDuplicatesMock = """
public class SimpleDuplicateMock: SimpleDuplicate {
    
    public init() {
        
    }
    
    var pushCallCount = 0
    var pushHandler: ((Double, Int, Float?) -> ())?
    public func push(state: Double, attachTransition: Int, detachTransition: Float?)  {
        pushCallCount += 1
        if let pushHandler = pushHandler {
            return pushHandler(state, attachTransition, detachTransition)
        }
        
    }
    var pushStateCallCount = 0
    var pushStateHandler: ((Double, Float, Int, Float?) -> ())?
    public func push(state: Double, flag: Float, attachTransition: Int, detachTransition: Float?)  {
        pushStateCallCount += 1
        if let pushStateHandler = pushStateHandler {
            return pushStateHandler(state, flag, attachTransition, detachTransition)
        }
        
    }
}
"""
