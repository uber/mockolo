import MockoloFramework

let someParameterOptionalType = """
/// @mockable
public protocol OpaqueTypeProtocol {
    func nonOptional(_ type: some Error) -> Int
    func optional(_ type: (some Error)?)
}
"""

let someParameterOptionalTypeMock = """


public class OpaqueTypeProtocolMock: OpaqueTypeProtocol {
    public init() { }


    public private(set) var nonOptionalCallCount = 0
    public var nonOptionalHandler: ((any Error) -> Int)?
    public func nonOptional(_ type: some Error) -> Int {
        nonOptionalCallCount += 1
        if let nonOptionalHandler = nonOptionalHandler {
            return nonOptionalHandler(type)
        }
        return 0
    }

    public private(set) var optionalCallCount = 0
    public var optionalHandler: (((any Error)?) -> ())?
    public func optional(_ type: (some Error)?) {
        optionalCallCount += 1
        if let optionalHandler = optionalHandler {
            optionalHandler(type)
        }

    }
}


"""

let someMultiParameterOptionalType = """
/// @mockable
public protocol OpaqueTypeWithMultiTypeProtocol {
    func nonOptional(_ type: some Error) -> Int
    func optional(_ type: ((some (Error & Foo)))?)
    func multiParam(_ typeA: some Error, _ typeB: some Error)
}
"""

let someMultiParameterOptionalTypeMock = """


public class OpaqueTypeWithMultiTypeProtocolMock: OpaqueTypeWithMultiTypeProtocol {
    public init() { }


    public private(set) var nonOptionalCallCount = 0
    public var nonOptionalHandler: ((any Error) -> Int)?
    public func nonOptional(_ type: some Error) -> Int {
        nonOptionalCallCount += 1
        if let nonOptionalHandler = nonOptionalHandler {
            return nonOptionalHandler(type)
        }
        return 0
    }

    public private(set) var optionalCallCount = 0
    public var optionalHandler: ((((any (Error & Foo)))?) -> ())?
    public func optional(_ type: ((some (Error & Foo)))?) {
        optionalCallCount += 1
        if let optionalHandler = optionalHandler {
            optionalHandler(type)
        }

    }

    public private(set) var multiParamCallCount = 0
    public var multiParamHandler: ((any Error, any Error) -> ())?
    public func multiParam(_ typeA: some Error, _ typeB: some Error) {
        multiParamCallCount += 1
        if let multiParamHandler = multiParamHandler {
            multiParamHandler(typeA, typeB)
        }

    }
}
"""

let closureReturningSomeType = """
/// @mockable
protocol ProtocolReturningOpaqueTypeInClosureProtocol {
    func register(router: @autoclosure @escaping () -> (some MyAwesomeType))
}
"""


let closureReturningSomeTypeMock = """


class ProtocolReturningOpaqueTypeInClosureProtocolMock: ProtocolReturningOpaqueTypeInClosureProtocol {
    init() { }


    private(set) var registerCallCount = 0
    var registerHandler: ((@autoclosure @escaping () -> (any MyAwesomeType)) -> ())?
    func register(router: @autoclosure @escaping () -> (some MyAwesomeType)) {
        registerCallCount += 1
        if let registerHandler = registerHandler {
            registerHandler(router())
        }

    }
}


"""
