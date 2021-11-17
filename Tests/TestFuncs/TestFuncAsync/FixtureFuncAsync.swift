import MockoloFramework

let funcAsync = """
import Foundation

/// \(String.mockAnnotation)
protocol FuncAsync {
    func f1(arg: Int) async -> String
    func f2(arg: Int) async
    func g1(arg: (Int) async -> ())
                async -> String
    func g2(arg: (Int) async -> ()) async
    func update<T, U>(arg1: T, arg2: @escaping (U) async -> ()) async -> ((T) -> (U))
}
"""

let funcAsyncMock =
"""

import Foundation


class FuncAsyncMock: FuncAsync {
    init() { }


    private(set) var f1CallCount = 0
    var f1Handler: ((Int) async -> (String))?
    func f1(arg: Int) async -> String {
        f1CallCount += 1
        if let f1Handler = f1Handler {
            return await f1Handler(arg)
        }
        return ""
    }

    private(set) var f2CallCount = 0
    var f2Handler: ((Int) async -> ())?
    func f2(arg: Int) async  {
        f2CallCount += 1
        if let f2Handler = f2Handler {
            await f2Handler(arg)
        }

    }

    private(set) var g1CallCount = 0
    var g1Handler: (((Int) async -> ()) async -> (String))?
    func g1(arg: (Int) async -> ()) async -> String {
        g1CallCount += 1
        if let g1Handler = g1Handler {
            return await g1Handler(arg)
        }
        return ""
    }

    private(set) var g2CallCount = 0
    var g2Handler: (((Int) async -> ()) async -> ())?
    func g2(arg: (Int) async -> ()) async  {
        g2CallCount += 1
        if let g2Handler = g2Handler {
            await g2Handler(arg)
        }

    }

    private(set) var updateCallCount = 0
    var updateHandler: ((Any, Any) async -> (Any))?
    func update<T, U>(arg1: T, arg2: @escaping (U) async -> ()) async -> ((T) -> (U)) {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return await updateHandler(arg1, arg2) as! ((T) -> (U))
        }
        fatalError("updateHandler returns can't have a default value thus its handler must be set")
    }
}

"""

let funcAsyncThrows = """
import Foundation

/// \(String.mockAnnotation)
protocol FuncAsyncThrows {
    func f1(arg: Int) async throws -> String
    func f2(arg: Int) async throws
    func g1(arg: (Int) async throws -> ())
                async
                throws -> String
    func g2(arg: (Int) async throws -> ()) async throws
    func update<T, U>(arg1: T, arg2: @escaping (U) async throws -> ()) async throws -> ((T) -> (U))
}
"""

let funcAsyncThrowsMock = """

import Foundation


class FuncAsyncThrowsMock: FuncAsyncThrows {
    init() { }


    private(set) var f1CallCount = 0
    var f1Handler: ((Int) async throws -> (String))?
    func f1(arg: Int) async throws -> String {
        f1CallCount += 1
        if let f1Handler = f1Handler {
            return try await f1Handler(arg)
        }
        return ""
    }

    private(set) var f2CallCount = 0
    var f2Handler: ((Int) async throws -> ())?
    func f2(arg: Int) async throws  {
        f2CallCount += 1
        if let f2Handler = f2Handler {
            try await f2Handler(arg)
        }

    }

    private(set) var g1CallCount = 0
    var g1Handler: (((Int) async throws -> ()) async throws -> (String))?
    func g1(arg: (Int) async throws -> ()) async throws -> String {
        g1CallCount += 1
        if let g1Handler = g1Handler {
            return try await g1Handler(arg)
        }
        return ""
    }

    private(set) var g2CallCount = 0
    var g2Handler: (((Int) async throws -> ()) async throws -> ())?
    func g2(arg: (Int) async throws -> ()) async throws  {
        g2CallCount += 1
        if let g2Handler = g2Handler {
            try await g2Handler(arg)
        }

    }

    private(set) var updateCallCount = 0
    var updateHandler: ((Any, Any) async throws -> (Any))?
    func update<T, U>(arg1: T, arg2: @escaping (U) async throws -> ()) async throws -> ((T) -> (U)) {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return try await updateHandler(arg1, arg2) as! ((T) -> (U))
        }
        fatalError("updateHandler returns can't have a default value thus its handler must be set")
    }
}

"""
