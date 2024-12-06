import MockoloFramework

let asyncThrowsVars = """
/// @mockable
public protocol AsyncThrowsVars {
    var getOnly: Int { get }
    static var getAndSet: Int { get set }
    var getAndThrows: MyValue { get throws }
    static var getAndAsync: MyValue { get async }
    var getAndAsyncAndThrows: Int { get async throws(any Error) }
}
"""

let asyncThrowsVarsMock = """
public class AsyncThrowsVarsMock: AsyncThrowsVars {
    public init() { }
    public init(getOnly: Int = 0, getAndThrows: MyValue, getAndAsyncAndThrows: Int = 0) {
        self.getOnly = getOnly
        self.getAndThrowsHandler = { getAndThrows }
        self.getAndAsyncAndThrowsHandler = { getAndAsyncAndThrows }
    }



    public var getOnly: Int = 0

    public static private(set) var getAndSetSetCallCount = 0
    public static var getAndSet: Int = 0 { didSet { getAndSetSetCallCount += 1 } }

    public var getAndThrowsHandler: (() throws -> MyValue)?
    public var getAndThrows: MyValue {
        get throws {
            if let getAndThrowsHandler = getAndThrowsHandler {
                return try getAndThrowsHandler()
            }
            fatalError("getAndThrowsHandler returns can't have a default value thus its handler must be set")
        }
    }

    public static var getAndAsyncHandler: (() async -> MyValue)?
    public static var getAndAsync: MyValue {
        get async {
            if let getAndAsyncHandler = getAndAsyncHandler {
                return await getAndAsyncHandler()
            }
            fatalError("getAndAsyncHandler returns can't have a default value thus its handler must be set")
        }
    }

    public var getAndAsyncAndThrowsHandler: (() async throws(any Error) -> Int)?
    public var getAndAsyncAndThrows: Int {
        get async throws(any Error) {
            if let getAndAsyncAndThrowsHandler = getAndAsyncAndThrowsHandler {
                return try await getAndAsyncAndThrowsHandler()
            }
            return 0
        }
    }
}
"""

let throwsNeverVars = """
/// @mockable
protocol P {
    var foo: Int { get throws(Never) }
}
"""

let throwsNeverVarsMock = """
class PMock: P {
    init() { }
    init(foo: Int = 0) {
        self.fooHandler = { foo }
    }


    var fooHandler: (() throws(Never) -> Int)?
    var foo: Int {
        get throws(Never) {
            if let fooHandler = fooHandler {
                return fooHandler()
            }
            return 0
        }
    }
}
"""
