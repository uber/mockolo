import MockoloFramework


let simpleDuplicates = """
/// \(String.mockAnnotation)
public protocol SimpleDuplicate {
func remove(_ arg: Int)
func remove(_ arg: String)
func remove(_ arg: Float)
func remove(_ arg: Double)
func push(state: Double, attachTransition: Int, detachTransition: Float?)
func push(state: Double, flag: Float, attachTransition: Int, detachTransition: Float?)
}
"""

let simpleDuplicatesMock =
"""
public class SimpleDuplicateMock: SimpleDuplicate {
    
    
    public init() {
        
    }
    var removeCallCount = 0
    public var removeHandler: ((Int) -> ())?
    public func remove(_ arg: Int)  {
        removeCallCount += 1
        if let removeHandler = removeHandler {
            removeHandler(arg)
        }
        
    }
    var removeArgCallCount = 0
    public var removeArgHandler: ((String) -> ())?
    public func remove(_ arg: String)  {
        removeArgCallCount += 1
        if let removeArgHandler = removeArgHandler {
            removeArgHandler(arg)
        }
        
    }
    var removeArgFloatCallCount = 0
    public var removeArgFloatHandler: ((Float) -> ())?
    public func remove(_ arg: Float)  {
        removeArgFloatCallCount += 1
        if let removeArgFloatHandler = removeArgFloatHandler {
            removeArgFloatHandler(arg)
        }
        
    }
    var removeArgDoubleCallCount = 0
    public var removeArgDoubleHandler: ((Double) -> ())?
    public func remove(_ arg: Double)  {
        removeArgDoubleCallCount += 1
        if let removeArgDoubleHandler = removeArgDoubleHandler {
            removeArgDoubleHandler(arg)
        }
        
    }
    var pushCallCount = 0
    public var pushHandler: ((Double, Int, Float?) -> ())?
    public func push(state: Double, attachTransition: Int, detachTransition: Float?)  {
        pushCallCount += 1
        if let pushHandler = pushHandler {
            pushHandler(state, attachTransition, detachTransition)
        }
        
    }
    var pushStateCallCount = 0
    public var pushStateHandler: ((Double, Float, Int, Float?) -> ())?
    public func push(state: Double, flag: Float, attachTransition: Int, detachTransition: Float?)  {
        pushStateCallCount += 1
        if let pushStateHandler = pushStateHandler {
            pushStateHandler(state, flag, attachTransition, detachTransition)
        }
        
    }
}


"""
