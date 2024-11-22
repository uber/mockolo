func applyConcurrencyHelpersTemplate() -> String {
    return #"""
fileprivate func warnIfNotSendable<each T>(function: String = #function, _: repeat each T) {
    print("At \(function), the captured arguments are not Sendable, it is not concurrency-safe.")
}

fileprivate func warnIfNotSendable<each T: Sendable>(function: String = #function, _: repeat each T) {
}

/// Will be replaced to `Synchronization.Mutex` in future.
fileprivate final class MockoloMutex<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: Value
    init(_ initialValue: Value) {
        self.value = initialValue
    }
#if compiler(>=6.0)
    borrowing func withLock<Result, E: Error>(_ body: (inout sending Value) throws(E) -> Result) throws(E) -> sending Result {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
#else
    func withLock<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
#endif
}

fileprivate struct MockoloUnsafeTransfer<Value>: @unchecked Sendable {
    var value: Value
    init<each T>(_ value: repeat each T) where Value == (repeat each T) {
        self.value = (repeat each value)
    }
}

fileprivate struct MockoloHandlerState<Arg, Handler> {
    var argValues: [MockoloUnsafeTransfer<Arg>] = []
    var handler: Handler? = nil
    var callCount: Int = 0
}
"""#
}
