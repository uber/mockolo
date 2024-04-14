import MockoloFramework

let sendableProtocol = """
/// \(String.mockAnnotation)
public protocol SendableProtocol: Sendable {
    func update(arg: Int) -> String
}
"""

let sendableProtocolMock = """



public class SendableProtocolMock: SendableProtocol, @unchecked Sendable {
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

let uncheckedSendableClass = """
/// \(String.mockAnnotation)
public class UncheckedSendableClass: @unchecked Sendable {
    func update(arg: Int) -> String
}
"""

let uncheckedSendableClassMock = """



public class UncheckedSendableClassMock: UncheckedSendableClass, @unchecked Sendable {
    public init() { }


    private(set) var updateCallCount = 0
    var updateHandler: ((Int) -> (String))?
    override func update(arg: Int) -> String {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        return ""
    }
}

"""

let confirmedSendableProtocol = """
public protocol SendableSendable: Sendable {
    func update(arg: Int) -> String
}

/// \(String.mockAnnotation)
public protocol ConfirmedSendableProtocol: SendableSendable {
}
"""

let confirmedSendableProtocolMock = """



public class ConfirmedSendableProtocolMock: ConfirmedSendableProtocol, @unchecked Sendable {
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
