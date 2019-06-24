import MockoloFramework

let funcThrow = """
import Foundation

/// \(String.mockAnnotation)
protocol FuncThrow {
    func f1(arg: Int) throws -> String
    func f2(arg: (Int) throws -> ()) throws -> String
    func f3(arg: (Int) throws -> ()) rethrows -> String
    func f4<T, U>(arg1: T, arg2: @escaping (U) throws -> ()) throws -> ((T) -> (U))
}
"""

let funcThrowMock = """
import Foundation

class FuncThrowMock: FuncThrow {
    
    init() {
        
    }
    var f1CallCount = 0
    var f1Handler: ((Int) throws -> (String))?
    func f1(arg: Int) throws -> String {
        f1CallCount += 1
        if let f1Handler = f1Handler {
            return try! f1Handler(arg)
        }
        return ""
    }
    var f2CallCount = 0
    var f2Handler: (((Int) throws -> ()) throws -> (String))?
    func f2(arg: (Int) throws -> ()) throws -> String {
        f2CallCount += 1
        if let f2Handler = f2Handler {
            return try! f2Handler(arg)
        }
        return ""
    }
    var f3CallCount = 0
    var f3Handler: (((Int) throws -> ()) throws -> (String))?
    func f3(arg: (Int) throws -> ()) rethrows -> String {
        f3CallCount += 1
        if let f3Handler = f3Handler {
            return try! f3Handler(arg)
        }
        return ""
    }
    var f4CallCount = 0
    var f4Handler: ((Any, Any) throws -> (Any))?
    func f4<T, U>(arg1: T, arg2: @escaping (U) throws -> ()) throws -> ((T) -> (U)) {
        f4CallCount += 1
        if let f4Handler = f4Handler {
            return try! f4Handler(arg1, arg2) as! ((T) -> (U))
        }
        fatalError("f4Handler returns can't have a default value thus its handler must be set")
    }
}

"""
