import MockoloFramework

let simpleFuncs = """
import Foundation

/// \(String.mockAnnotation)
public protocol SimpleFunc {
    func update(arg: Int) -> String
}
"""

let simpleFuncsMock = """

import Foundation

public class SimpleFuncMock: SimpleFunc {
    public init() { }


    public private(set) var updateCallCount = 0
    public var updateHandler: ((Int) -> (String))?
    public func update(arg: Int) -> String {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        return ""
    }
}

"""


let simpleFuncsAllowCallCountMock = """

import Foundation

public class SimpleFuncMock: SimpleFunc {
    public init() { }


    public var updateCallCount = 0
    public var updateHandler: ((Int) -> (String))?
    public func update(arg: Int) -> String {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        return ""
    }
}

"""

let simpleMockFuncMock = """

import Foundation

public class SimpleFuncMock: SimpleFunc {
    public init() { }


    public private(set) var updateCallCount = 0
    public var updateHandler: ((Int) -> (String))?
    public func update(arg: Int) -> String {
        mockFunc(&updateCallCount)("update", updateHandler?(arg), .val(""))
    }
}

"""
