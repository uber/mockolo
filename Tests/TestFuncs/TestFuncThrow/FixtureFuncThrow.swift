import MockoloFramework


let funcThrow2 = """
import Foundation

/// \(String.mockAnnotation)
protocol FuncThrow {
func update<T>(arg1: T, arg2: () throws -> T) rethrows -> T
func update<T, U>(arg1: T, arg2: @escaping (U) throws -> ()) throws -> ((T) -> (U))
}
"""

let funcThrow = """
import Foundation

/// \(String.mockAnnotation)
protocol FuncThrow {
    func f1(arg: Int) throws -> String
    func f2(arg: Int) throws
    func g1(arg: (Int) throws -> ())
                throws -> String
    func g2(arg: (Int) throws -> ()) throws
    func h(arg: (Int) throws -> ()) rethrows -> String
    func update<T, U>(arg1: T, arg2: @escaping (U) throws -> ()) throws -> ((T) -> (U))
    func update<T>(arg1: T, arg2: () throws -> T) rethrows -> T
}
"""

let funcThrowMock =
"""

import Foundation


class FuncThrowMock: FuncThrow {
    init() { }


    private(set) var f1CallCount = 0
    var f1Handler: ((Int) throws -> (String))?
    func f1(arg: Int) throws -> String {
        f1CallCount += 1
        if let f1Handler = f1Handler {
            return try f1Handler(arg)
        }
        return ""
    }

    private(set) var f2CallCount = 0
    var f2Handler: ((Int) throws -> ())?
    func f2(arg: Int) throws  {
        f2CallCount += 1
        if let f2Handler = f2Handler {
            try f2Handler(arg)
        }
        
    }

    private(set) var g1CallCount = 0
    var g1Handler: (((Int) throws -> ()) throws -> (String))?
    func g1(arg: (Int) throws -> ()) throws -> String {
        g1CallCount += 1
        if let g1Handler = g1Handler {
            return try g1Handler(arg)
        }
        return ""
    }

    private(set) var g2CallCount = 0
    var g2Handler: (((Int) throws -> ()) throws -> ())?
    func g2(arg: (Int) throws -> ()) throws  {
        g2CallCount += 1
        if let g2Handler = g2Handler {
            try g2Handler(arg)
        }
        
    }

    private(set) var hCallCount = 0
    var hHandler: (((Int) throws -> ()) throws -> (String))?
    func h(arg: (Int) throws -> ()) rethrows -> String {
        hCallCount += 1
        if let hHandler = hHandler {
            return try hHandler(arg)
        }
        return ""
    }

    private(set) var updateCallCount = 0
    var updateHandler: ((Any, Any) throws -> (Any))?
    func update<T, U>(arg1: T, arg2: @escaping (U) throws -> ()) throws -> ((T) -> (U)) {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return try updateHandler(arg1, arg2) as! ((T) -> (U))
        }
        fatalError("updateHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var updateArg1CallCount = 0
    var updateArg1Handler: ((Any, () throws -> Any) throws -> (Any))?
    func update<T>(arg1: T, arg2: () throws -> T) rethrows -> T {
        updateArg1CallCount += 1
        if let updateArg1Handler = updateArg1Handler {
            return try updateArg1Handler(arg1, arg2) as! T
        }
        fatalError("updateArg1Handler returns can't have a default value thus its handler must be set")
    }
}


"""
