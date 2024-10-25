import MockoloFramework

let asyncThrowsVars = """
/// \(String.mockAnnotation)
public protocol AsyncThrowsVars {
    var getOnly: Int { get }
    static var getAndSet: Int { get set }
    var getAndThrows: Int { get throws }
    static var getAndAsync: Int { get async }
    var getAndAsyncAndThrows: Int { get async throws(any Error) }
}
"""

let asyncThrowsVarsMock = """
public class AsyncThrowsVarsMock: AsyncThrowsVars {
    public init() { }
    public init(getOnly: Int = 0, getAndThrows: Int = 0, getAndAsyncAndThrows: Int = 0) {
        self.getOnly = getOnly
        self.getAndThrowsHandler = { getAndThrows }
        self.getAndAsyncAndThrowsHandler = { getAndAsyncAndThrows }
    }



    public var getOnly: Int = 0

    public static private(set) var getAndSetSetCallCount = 0
    public static var getAndSet: Int = 0 { didSet { getAndSetSetCallCount += 1 } }
    public var getAndThrowsHandler: (() throws -> Int)?
    public var getAndThrows: Int {
        get throws { try getAndThrowsHandler!() }
    }
    public static var getAndAsyncHandler: (() async -> Int)?
    public static var getAndAsync: Int {
        get async { await getAndAsyncHandler!() }
    }
    public var getAndAsyncAndThrowsHandler: (() async throws(any Error) -> Int)?
    public var getAndAsyncAndThrows: Int {
        get async throws(any Error) { try await getAndAsyncAndThrowsHandler!() }
    }
}
"""

