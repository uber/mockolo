#if compiler(>=6.0)
import MockoloFramework

// Async/throwing getters use the handler-backed `.computed` path (no backing store): the counter
// is declared and bumped as the first statement of the getter body, before any `await`/`throw`.
@Fixture enum getterHistoryAsync {
    /// @mockable(getter: all = true)
    public protocol GHAsync {
        var value: Int { get async }
        var name: String { get throws }
        var session: Int { get async throws }
    }

    @Fixture enum expected {
        public class GHAsyncMock: GHAsync {
            public init() { }
            public init(value: Int = 0, name: String = "", session: Int = 0) {
                self.valueHandler = { value }
                self.nameHandler = { name }
                self.sessionHandler = { session }
            }
            public private(set) var valueGetCallCount = 0
            public var valueHandler: (() async -> Int)?
            public var value: Int {
                get async {
                    valueGetCallCount += 1
                    if let valueHandler = valueHandler {
                        return await valueHandler()
                    }
                    return 0
                }
            }
            public private(set) var nameGetCallCount = 0
            public var nameHandler: (() throws -> String)?
            public var name: String {
                get throws {
                    nameGetCallCount += 1
                    if let nameHandler = nameHandler {
                        return try nameHandler()
                    }
                    return ""
                }
            }
            public private(set) var sessionGetCallCount = 0
            public var sessionHandler: (() async throws -> Int)?
            public var session: Int {
                get async throws {
                    sessionGetCallCount += 1
                    if let sessionHandler = sessionHandler {
                        return try await sessionHandler()
                    }
                    return 0
                }
            }
        }
    }
}
#endif
