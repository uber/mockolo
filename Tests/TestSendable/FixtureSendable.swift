import MockoloFramework

let sendableProtocol = """
import Foundation

/// \(String.mockAnnotation)
public protocol SendableProtocol: Sendable {
    func update(arg: Int) -> String
}
"""

let sendableProtocolMock = """

import Foundation

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
import Foundation

/// \(String.mockAnnotation)
public class UncheckedSendableClass: @unchecked Sendable {
    func update(arg: Int) -> String
}
"""

let uncheckedSendableClassMock = """

import Foundation

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
import Foundation

public protocol SendableSendable: Sendable {
    func update(arg: Int) -> String
}

/// \(String.mockAnnotation)
public protocol ConfirmedSendableProtocol: SendableSendable {
}
"""

let confirmedSendableProtocolMock = """

import Foundation

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
