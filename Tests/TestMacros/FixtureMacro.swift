import MockoloFramework

let macroImports = """
import X
import Y

#if canImport(NewFramework)
import Z
import W
#endif

import V

/// \(String.mockAnnotation)
public protocol SomeProtocol: Parent {
    func run()
}
"""

let macroImportsMock = """

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
    public func run()  {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler()
        }
        
    }
}

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
    public func run()  {
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
#if DEBUG
import P
#endif
#if canImport(NewFramework)
import W
import Z
#endif


public class SomeProtocolMock: SomeProtocol {
    public init() { }


    public private(set) var runCallCount = 0
    public var runHandler: (() -> ())?
    public func run()  {
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

/// \(String.mockAnnotation)
public protocol SomeProtocol: Parent {
    func run()
}
"""


let ifElseMacroImportsMock = """

import A
import B
import C
#if DEBUG
import X
import Y
#endif
#if TEST
import Z
#endif


public class SomeProtocolMock: SomeProtocol {
    public init() { }


    public private(set) var runCallCount = 0
    public var runHandler: (() -> ())?
    public func run()  {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler()
        }
        
    }
}

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

/// \(String.mockAnnotation)
public protocol SomeProtocol: Parent {
    func run()
}
"""

let nestedMacroImportsMock = """

import A
import B
import C
#if DEBUG
#if TEST
import Y
#endif
import X
#endif


public class SomeProtocolMock: SomeProtocol {
    public init() { }


    public private(set) var runCallCount = 0
    public var runHandler: (() -> ())?
    public func run()  {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler()
        }
        
    }
}
"""

let macroInFunc =
"""
/// \(String.mockAnnotation)
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
    func run()  {
        runCallCount += 1
        if let runHandler = runHandler {
            runHandler()
        }
        
    }
    #if DEBUG

    private(set) var showDebugModeCallCount = 0
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
