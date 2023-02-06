import MockoloFramework

let someParameterOptionalType = """
/// \(String.mockAnnotation)
public protocol OpaqueReturnTypeProtocol {
    func nonOptional(_ type: some Error) -> Int
    func optional(_ type: (some Error)?)
}
"""

let someParameterOptionalTypeMock = """


public class OpaqueReturnTypeProtocolMock: OpaqueReturnTypeProtocol {
    public init() { }


    public private(set) var nonOptionalCallCount = 0
    public var nonOptionalHandler: ((Any) -> (Int))?
    public func nonOptional(_ type: some Error) -> Int {
        nonOptionalCallCount += 1
        if let nonOptionalHandler = nonOptionalHandler {
            return nonOptionalHandler(type)
        }
        return 0
    }

    public private(set) var optionalCallCount = 0
    public var optionalHandler: ((Any?) -> ())?
    public func optional(_ type: (some Error)?)  {
        optionalCallCount += 1
        if let optionalHandler = optionalHandler {
            optionalHandler(type)
        }

    }
}


"""

let someMultiParameterOptionalType = """
/// \(String.mockAnnotation)
public protocol OpaqueReturnTypeWithMultiTypeProtocol {
    func nonOptional(_ type: some Error) -> Int
    func optional(_ type: ((some (Error & Foo)))?)
}
"""


let someMultiParameterOptionalTypeMock = """


public class OpaqueReturnTypeWithMultiTypeProtocolMock: OpaqueReturnTypeWithMultiTypeProtocol {
    public init() { }


    public private(set) var nonOptionalCallCount = 0
    public var nonOptionalHandler: ((Any) -> (Int))?
    public func nonOptional(_ type: some Error) -> Int {
        nonOptionalCallCount += 1
        if let nonOptionalHandler = nonOptionalHandler {
            return nonOptionalHandler(type)
        }
        return 0
    }

    public private(set) var optionalCallCount = 0
    public var optionalHandler: ((Any?) -> ())?
    public func optional(_ type: ((some (Error & Foo)))?)  {
        optionalCallCount += 1
        if let optionalHandler = optionalHandler {
            optionalHandler(type)
        }

    }
}


"""
