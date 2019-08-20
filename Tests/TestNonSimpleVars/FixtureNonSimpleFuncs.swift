import MockoloFramework

let variadicFunc = """
import Foundation

/// \(String.mockAnnotation)
protocol NonSimpleFuncs {
    func bar(_ arg: String, x: Int..., y: [Double]) -> Float?
}
"""

let variadicFuncMock =
"""
import Foundation

class NonSimpleFuncsMock: NonSimpleFuncs {
    private var _doneInit = false
    init() {
        _doneInit = true
    }
    
    var barCallCount = 0
    var barHandler: ((String, Int..., [Double]) -> (Float?))?
    func bar(_ arg: String, x: Int..., y: [Double]) -> Float? {
        barCallCount += 1
        
        if let barHandler = barHandler {
            return barHandler(arg, x, y)
        }
        return nil
    }
}

"""


let autoclosureArgFunc = """
import Foundation

/// \(String.mockAnnotation)
protocol NonSimpleFuncs {
func pass<T>(handler: @autoclosure () -> Int) rethrows -> T
}
"""

let autoclosureArgFuncMock = """
import Foundation


class NonSimpleFuncsMock: NonSimpleFuncs {
    
    private var _doneInit = false
    
    init() {
        
        _doneInit = true
    }
    
    var passCallCount = 0
    var passHandler: ((@autoclosure () -> Int) throws -> (Any))?
    func pass<T>(handler: @autoclosure () -> Int) rethrows -> T {
        passCallCount += 1
        
        if let passHandler = passHandler {
            return try passHandler(handler()) as! T
        }
        fatalError("passHandler returns can't have a default value thus its handler must be set")
    }
}

"""


let closureArgFunc = """
import Foundation

/// \(String.mockAnnotation)
protocol NonSimpleFuncs {
func cat<T>(named arg: String, tags: [String: String]?, closure: () throws -> T) rethrows -> T
func more<T>(named arg: String, tags: [String: String]?, closure: (T) throws -> ()) rethrows -> T
}
"""


let closureArgFuncMock = """

import Foundation
class NonSimpleFuncsMock: NonSimpleFuncs {
    private var _doneInit = false
    init() {
        _doneInit = true
    }
    
    var catCallCount = 0
    var catHandler: ((String, [String: String]?, () throws -> Any) throws -> (Any))?
    func cat<T>(named arg: String, tags: [String: String]?, closure: () throws -> T) rethrows -> T {
        catCallCount += 1
        
        if let catHandler = catHandler {
            return try catHandler(arg, tags, closure) as! T
        }
        fatalError("catHandler returns can't have a default value thus its handler must be set")
    }
    
    var moreCallCount = 0
    var moreHandler: ((String, [String: String]?, (Any) throws -> ()) throws -> (Any))?
    func more<T>(named arg: String, tags: [String: String]?, closure: (T) throws -> ()) rethrows -> T {
        moreCallCount += 1
        
        if let moreHandler = moreHandler {
            return try moreHandler(arg, tags, closure) as! T
        }
        fatalError("moreHandler returns can't have a default value thus its handler must be set")
    }
}
"""
