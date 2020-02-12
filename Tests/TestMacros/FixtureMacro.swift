import MockoloFramework


let macro =
"""
/// \(String.mockAnnotation)
protocol PresentableListener: class {
    func run()
    #if DEBUG
    func showDebugMode()
    #endif
}
"""

let macroMock = """

class PresentableListenerMock: PresentableListener {
    
    private var _doneInit = false
    
    init() { _doneInit = true }
    
    var runCallCount = 0
    var runHandler: (() -> ())?
    func run()  {
        runCallCount += 1

        if let runHandler = runHandler {
            runHandler()
        }
        
    }
    #if DEBUG
    var showDebugModeCallCount = 0
    var showDebugModeHandler: (() -> ())?
    func showDebugMode()  {
        showDebugModeCallCount += 1

        if let showDebugModeHandler = showDebugModeHandler {
            showDebugModeHandler()
        }
        
    }
    #endif
}

"""
