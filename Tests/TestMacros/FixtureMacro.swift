import MockoloFramework

let macroImports = """
import X
import Y

#if canImport(NewFramework)
import Z
import W
#endif

import V

\(FixtureHelpers.someProtocol)
"""

let macroImportsMock = """

import V
import X
import Y
#if canImport(NewFramework)
import W
import Z
#endif


\(FixtureHelpers.someProtocolMock)
"""



let parentMock = """
import Foundation

public class ParentMock: Parent {
    public init() {}
}
"""


let macroImportsWithParentMock = """
import Foundation
import V
import X
import Y
#if canImport(NewFramework)
import W
import Z
#endif


public class SomeProtocolMock: SomeProtocol {
    public init() { }

    public private(set) var runCallCount = 0
    public var runHandler: (() -> ())?
    public func run() {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler()
        }

    }
}

"""


let parentWithMacroMock = """
import Foundation
#if DEBUG
import P
#endif

public class ParentMock: Parent {
    public init() {}
}
"""

let inheritedMacroImportsMock = """

import Foundation
import V
import X
import Y
#if canImport(NewFramework)
import W
import Z
#endif
#if DEBUG
import P
#endif


public class SomeProtocolMock: SomeProtocol {
    public init() { }


    public private(set) var runCallCount = 0
    public var runHandler: (() -> ())?
    public func run() {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler()
        }
        
    }
}

"""
let ifElseMacroImports = """

import A
import B

#if DEBUG
import X
import Y
#elseif TEST
import Z
#endif

import C

\(FixtureHelpers.someProtocol)
"""


let ifElseMacroImportsMock = """

import A
import B
import C
#if DEBUG
import X
import Y
#elseif TEST
import Z
#endif


\(FixtureHelpers.someProtocolMock)
"""

let nestedMacroImports = """

import A
import B

#if DEBUG
import X
#if TEST
import Y
#endif
#endif

import C

\(FixtureHelpers.someProtocol)
"""

let nestedMacroImportsMock = """

import A
import B
import C
#if DEBUG
import X
#if TEST
import Y
#endif
#endif


\(FixtureHelpers.someProtocolMock)
"""

let macroInFunc =
"""
/// @mockable
protocol PresentableListener: class {
    func run()
    #if DEBUG
    func showDebugMode()
    #endif
}
"""

let macroInFuncMock = """



class PresentableListenerMock: PresentableListener {
    init() { }


    private(set) var runCallCount = 0
    var runHandler: (() -> ())?
    func run() {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler()
        }
        
    }
    #if DEBUG

    private(set) var showDebugModeCallCount = 0
    var showDebugModeHandler: (() -> ())?
    func showDebugMode() {
        showDebugModeCallCount += 1
        if let showDebugModeHandler = showDebugModeHandler {
            showDebugModeHandler()
        }
        
    }
    #endif
}

"""

let macroInFuncWithOverload = """
/// @mockable
protocol PresentableListener: AnyObject {
    #if DEBUG
    func run(value: Int)
    func run(value: String)
    #endif
}
"""

let macroInFuncWithOverloadMock = """



class PresentableListenerMock: PresentableListener {
    init() { }

    #if DEBUG

    private(set) var runCallCount = 0
    var runHandler: ((Int) -> ())?
    func run(value: Int) {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler(value)
        }
        
    }

    private(set) var runValueCallCount = 0
    var runValueHandler: ((String) -> ())?
    func run(value: String) {
        runValueCallCount += 1
        if let runValueHandler = runValueHandler {
            runValueHandler(value)
        }
        
    }
    #endif
}

"""

@Fixture
enum macroElseIfInFunc {
    /// @mockable
    protocol PresentableListener: AnyObject {
        func run()
        #if DEBUG
        func showDebugMode()
        #elseif TEST
        func showTestMode()
        #elseif FEATURE_X
        func showFeatureXMode()
        #else
        func showReleaseMode()
        #endif
    }

    @Fixture
    enum expected {
        class PresentableListenerMock: PresentableListener {
            init() { }


            private(set) var runCallCount = 0
            var runHandler: (() -> ())?
            func run() {
                runCallCount += 1
                if let runHandler = runHandler {
                    runHandler()
                }

            }
            #if DEBUG

            private(set) var showDebugModeCallCount = 0
            var showDebugModeHandler: (() -> ())?
            func showDebugMode() {
                showDebugModeCallCount += 1
                if let showDebugModeHandler = showDebugModeHandler {
                    showDebugModeHandler()
                }

            }
            #elseif TEST

            private(set) var showTestModeCallCount = 0
            var showTestModeHandler: (() -> ())?
            func showTestMode() {
                showTestModeCallCount += 1
                if let showTestModeHandler = showTestModeHandler {
                    showTestModeHandler()
                }

            }
            #elseif FEATURE_X

            private(set) var showFeatureXModeCallCount = 0
            var showFeatureXModeHandler: (() -> ())?
            func showFeatureXMode() {
                showFeatureXModeCallCount += 1
                if let showFeatureXModeHandler = showFeatureXModeHandler {
                    showFeatureXModeHandler()
                }

            }
            #else

            private(set) var showReleaseModeCallCount = 0
            var showReleaseModeHandler: (() -> ())?
            func showReleaseMode() {
                showReleaseModeCallCount += 1
                if let showReleaseModeHandler = showReleaseModeHandler {
                    showReleaseModeHandler()
                }

            }
            #endif
        }
    }
}


let macroSamePreprocessorMacroName = """
#if DEBUG
import Foundation
#elseif FEATURE_X
import FeatureX
#elseif TEST
import Testing
#else
import Production
#endif

/// @mockable
protocol PresentableListener: AnyObject {
    func run()
    #if DEBUG
    func showDebugMode()
    #elseif FEATURE_X
    func showFeatureXMode()
    #elseif TEST
    func showTestMode()
    #else
    func showReleaseMode()
    #endif
}
"""

let macroSamePreprocessorMacroNameMock = """



#if DEBUG
import Foundation
#elseif FEATURE_X
import FeatureX
#elseif TEST
import Testing
#else
import Production
#endif


class PresentableListenerMock: PresentableListener {
    init() { }


    private(set) var runCallCount = 0
    var runHandler: (() -> ())?
    func run() {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler()
        }
        
    }
    #if DEBUG

    private(set) var showDebugModeCallCount = 0
    var showDebugModeHandler: (() -> ())?
    func showDebugMode() {
        showDebugModeCallCount += 1
        if let showDebugModeHandler = showDebugModeHandler {
            showDebugModeHandler()
        }
        
    }
    #elseif FEATURE_X

    private(set) var showFeatureXModeCallCount = 0
    var showFeatureXModeHandler: (() -> ())?
    func showFeatureXMode() {
        showFeatureXModeCallCount += 1
        if let showFeatureXModeHandler = showFeatureXModeHandler {
            showFeatureXModeHandler()
        }
        
    }
    #elseif TEST

    private(set) var showTestModeCallCount = 0
    var showTestModeHandler: (() -> ())?
    func showTestMode() {
        showTestModeCallCount += 1
        if let showTestModeHandler = showTestModeHandler {
            showTestModeHandler()
        }
        
    }
    #else

    private(set) var showReleaseModeCallCount = 0
    var showReleaseModeHandler: (() -> ())?
    func showReleaseMode() {
        showReleaseModeCallCount += 1
        if let showReleaseModeHandler = showReleaseModeHandler {
            showReleaseModeHandler()
        }
        
    }
    #endif
}

"""

@Fixture
enum macroInVar {
    /// @mockable
    public protocol SomeProtocol {
        #if DEBUG
        var debug: String { get }
        #elseif FEATURE_X
        var featureX: String { get }
        #endif
        #if TEST
        func runTest()
        #elseif DEBUG
        func runDebug()
        #endif
    }

    @Fixture
    enum expected {
        public class SomeProtocolMock: SomeProtocol {
            public init() { }

            #if DEBUG


            public var debug: String = ""
            #elseif FEATURE_X


            public var featureX: String = ""
            #endif
            #if TEST

            public private(set) var runTestCallCount = 0
            public var runTestHandler: (() -> ())?
            public func runTest() {
                runTestCallCount += 1
                if let runTestHandler = runTestHandler {
                    runTestHandler()
                }
                
            }
            #elseif DEBUG

            public private(set) var runDebugCallCount = 0
            public var runDebugHandler: (() -> ())?
            public func runDebug() {
                runDebugCallCount += 1
                if let runDebugHandler = runDebugHandler {
                    runDebugHandler()
                }
                
            }
            #endif
        }

    }
}

let duplicatedImportsInMacro = """
import SomeImport1
import SomeImport1
@testable import SomeImport1
/// @mockable
protocol Simple {
}
"""

let duplicatedImportsInMacroMock = """
@testable import SomeImport1
class SimpleMock: Simple {
    init() { }
}
"""

let nestedMacro = """
#if canImport(NewFramework)
import Z
#if canImport(NewFramework2)
import W
#if canImport(NewFramework3)
import Z
#endif
#endif
#endif
/// @mockable
protocol Simple {
}
"""

let nestedMacroMock = """
#if canImport(NewFramework)
import Z
#if canImport(NewFramework2)
import W
#if canImport(NewFramework3)
import Z
#endif
#endif
#endif
class SimpleMock: Simple {
    init() { }
}
"""
