#if compiler(>=6.0)
import MockoloFramework

// `@unchecked Sendable` mock: the getter counter is a plain, unsynchronized property — it follows
// the existing `SetCallCount` model, NOT the method `MockoloMutex` model. This locks that behavior.
@Fixture enum getterHistorySendable {
    /// @mockable
    public protocol GHSendable: Sendable {
        var state: Int { get }
    }

    @Fixture(includesConcurrencyHelpers: true)
    enum expected {
        public final class GHSendableMock: GHSendable, @unchecked Sendable {
            public init() { }
            public init(state: Int = 0) {
                self._state = state
            }
            public private(set) var stateGetCallCount = 0
            private var _state: Int = 0
            public var state: Int {
                get { stateGetCallCount += 1; return _state }
                set { _state = newValue }
            }
        }
    }
}
#endif
