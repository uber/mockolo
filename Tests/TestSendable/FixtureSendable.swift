import MockoloFramework

let sendableProtocol = """
/// \(String.mockAnnotation)
public protocol SendableProtocol: Sendable {
    func update(arg: Int) -> String
    func update(arg0: some Sendable, arg1: AnyObject) async throws
}
"""

let sendableProtocolMock = #"""
public final class SendableProtocolMock: SendableProtocol {
    public init() { }


    private let updateState = MockoloMutex(MockoloHandlerState<Int, (Int) -> String>())
    public var updateCallCount: Int {
        return updateState.withLock(\.callCount)
    }
    public var updateArgValues: [Int] {
        return updateState.withLock(\.argValues).map(\.value)
    }
    public var updateHandler: ((Int) -> String)? {
        get { updateState.withLock(\.handler) }
        set { updateState.withLock { $0.handler = newValue } }
    }
    public func update(arg: Int) -> String {
        warnIfNotSendable(arg)
        let updateHandler = updateState.withLock { state in
            state.callCount += 1
            state.argValues.append(.init(arg))
            return state.handler
        }
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        return ""
    }

    private let updateArg0State = MockoloMutex(MockoloHandlerState<(Any, AnyObject), (Any, AnyObject) async throws -> ()>())
    public var updateArg0CallCount: Int {
        return updateArg0State.withLock(\.callCount)
    }
    public var updateArg0ArgValues: [(Any, AnyObject)] {
        return updateArg0State.withLock(\.argValues).map(\.value)
    }
    public var updateArg0Handler: ((Any, AnyObject) async throws -> ())? {
        get { updateArg0State.withLock(\.handler) }
        set { updateArg0State.withLock { $0.handler = newValue } }
    }
    public func update(arg0: some Sendable, arg1: AnyObject) async throws {
        warnIfNotSendable(arg0, arg1)
        let updateArg0Handler = updateArg0State.withLock { state in
            state.callCount += 1
            state.argValues.append(.init(arg0, arg1))
            return state.handler
        }
        if let updateArg0Handler = updateArg0Handler {
            try await updateArg0Handler(arg0, arg1)
        }
        
    }
}
"""#


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
    var updateHandler: ((Int) -> String)?
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
    public var updateHandler: ((Int) -> String)?
    public func update(arg: Int) -> String {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg)
        }
        return ""
    }
}
"""
