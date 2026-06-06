import Combine
import MockoloFramework

// Support type for non-defaultable / optional getter-tracking fixtures so the generated
// `expected` mocks compile as part of the test target.
struct CustomThing {}

@Fixture enum getterHistorySpecific {
    /// @mockable(getter: state = true)
    public protocol GHSpecific {
        var state: Int { get }
        var token: String { get }
    }

    @Fixture enum expected {
        public class GHSpecificMock: GHSpecific {
            public init() { }
            public init(state: Int = 0, token: String = "") {
                self._state = state
                self.token = token
            }
            public private(set) var stateGetCallCount = 0
            private var _state: Int = 0
            public var state: Int {
                get { stateGetCallCount += 1; return _state }
                set { _state = newValue }
            }
            public var token: String = ""
        }
    }
}

@Fixture enum getterHistoryAllExcept {
    /// @mockable(getter: all = true; token = false)
    public protocol GHAllExcept {
        var state: Int { get }
        var token: String { get }
    }

    @Fixture enum expected {
        public class GHAllExceptMock: GHAllExcept {
            public init() { }
            public init(state: Int = 0, token: String = "") {
                self._state = state
                self.token = token
            }
            public private(set) var stateGetCallCount = 0
            private var _state: Int = 0
            public var state: Int {
                get { stateGetCallCount += 1; return _state }
                set { _state = newValue }
            }
            public var token: String = ""
        }
    }
}

@Fixture enum getterHistoryGetSet {
    /// @mockable(getter: session = true)
    public protocol GHGetSet {
        var session: String { get set }
    }

    @Fixture enum expected {
        public class GHGetSetMock: GHGetSet {
            public init() { }
            public init(session: String = "") {
                self._session = session
            }
            public private(set) var sessionSetCallCount = 0
            public private(set) var sessionGetCallCount = 0
            private var _session: String = ""
            public var session: String {
                get { sessionGetCallCount += 1; return _session }
                set { _session = newValue; sessionSetCallCount += 1 }
            }
        }
    }
}

@Fixture enum getterHistoryNonDefault {
    /// @mockable(getter: item = true)
    public protocol GHNonDefault {
        var item: CustomThing { get }
    }

    @Fixture enum expected {
        public class GHNonDefaultMock: GHNonDefault {
            public init() { }
            public init(item: CustomThing) {
                self._item = item
            }
            public private(set) var itemGetCallCount = 0
            private var _item: CustomThing!
            public var item: CustomThing {
                get { itemGetCallCount += 1; return _item }
                set { _item = newValue }
            }
        }
    }
}

@Fixture enum getterHistoryOptionalGetOnly {
    /// @mockable(getter: item = true)
    public protocol GHOptional {
        var item: CustomThing? { get }
    }

    @Fixture enum expected {
        public class GHOptionalMock: GHOptional {
            public init() { }
            public init(item: CustomThing? = nil) {
                self._item = item
            }
            public private(set) var itemGetCallCount = 0
            private var _item: CustomThing? = nil
            public var item: CustomThing? {
                get { itemGetCallCount += 1; return _item }
                set { _item = newValue }
            }
        }
    }
}

@Fixture enum getterHistoryStatic {
    /// @mockable(getter: token = true)
    public protocol GHStatic {
        static var token: String { get }
    }

    @Fixture enum expected {
        public class GHStaticMock: GHStatic {
            public init() { }
            public static private(set) var tokenGetCallCount = 0
            static private var _token: String = ""
            public static var token: String {
                get { tokenGetCallCount += 1; return _token }
                set { _token = newValue }
            }
        }
    }
}

// A tracked sibling alongside an explicit `plain = false` opt-out: the opt-out get-set property
// must keep its existing `var = default { didSet }` shape (no churn on the settable path).
@Fixture enum getterHistoryGetSetOptOut {
    /// @mockable(getter: tracked = true; plain = false)
    public protocol GHGetSetOptOut {
        var tracked: Int { get }
        var plain: Int { get set }
    }

    @Fixture enum expected {
        public class GHGetSetOptOutMock: GHGetSetOptOut {
            public init() { }
            public init(tracked: Int = 0, plain: Int = 0) {
                self._tracked = tracked
                self.plain = plain
            }
            public private(set) var trackedGetCallCount = 0
            private var _tracked: Int = 0
            public var tracked: Int {
                get { trackedGetCallCount += 1; return _tracked }
                set { _tracked = newValue }
            }
            public private(set) var plainSetCallCount = 0
            public var plain: Int = 0 { didSet { plainSetCallCount += 1 } }
        }
    }
}

// No annotation; tracking is forced by the `--enable-getter-history` global flag.
@Fixture enum getterHistoryGlobalFlag {
    /// @mockable
    public protocol GHGlobalFlag {
        var state: Int { get }
        var name: String { get set }
    }

    @Fixture enum expected {
        public class GHGlobalFlagMock: GHGlobalFlag {
            public init() { }
            public init(state: Int = 0, name: String = "") {
                self._state = state
                self._name = name
            }
            public private(set) var stateGetCallCount = 0
            private var _state: Int = 0
            public var state: Int {
                get { stateGetCallCount += 1; return _state }
                set { _state = newValue }
            }
            public private(set) var nameSetCallCount = 0
            public private(set) var nameGetCallCount = 0
            private var _name: String = ""
            public var name: String {
                get { nameGetCallCount += 1; return _name }
                set { _name = newValue; nameSetCallCount += 1 }
            }
        }
    }
}

// Global flag on, but an explicit `token = false` opts that property out — proves explicit wins over the flag.
@Fixture enum getterHistoryGlobalFlagOptOut {
    /// @mockable(getter: token = false)
    public protocol GHGlobalOptOut {
        var state: Int { get }
        var token: String { get }
    }

    @Fixture enum expected {
        public class GHGlobalOptOutMock: GHGlobalOptOut {
            public init() { }
            public init(state: Int = 0, token: String = "") {
                self._state = state
                self.token = token
            }
            public private(set) var stateGetCallCount = 0
            private var _state: Int = 0
            public var state: Int {
                get { stateGetCallCount += 1; return _state }
                set { _state = newValue }
            }
            public var token: String = ""
        }
    }
}

// `--allow-set-call-count` composes: both counters drop `private(set)`.
@Fixture enum getterHistoryAllowSetCallCount {
    /// @mockable(getter: session = true)
    public protocol GHAllowSet {
        var session: String { get set }
    }

    @Fixture enum expected {
        public class GHAllowSetMock: GHAllowSet {
            public init() { }
            public init(session: String = "") {
                self._session = session
            }
            public var sessionSetCallCount = 0
            public var sessionGetCallCount = 0
            private var _session: String = ""
            public var session: String {
                get { sessionGetCallCount += 1; return _session }
                set { _session = newValue; sessionSetCallCount += 1 }
            }
        }
    }
}

// Class mock (`--mock-all`) + flag: getter tracking is a no-op (protocol-only guard).
@Fixture enum getterHistoryClassMockNoop {
    /// @mockable
    public class GHClass {
        public var state: Int = 0
        public init() {}
    }

    @Fixture enum expected {
        public class GHClassMock: GHClass {
            override public init() {
                super.init()
            }
            public private(set) var stateSetCallCount = 0
            public override var state: Int { didSet { stateSetCallCount += 1 } }
        }
    }
}

// Intercepted publisher/observable/wrapper/weak/dynamic props are never tracked; only `tracked` converts.
@Fixture(imports: ["Combine"]) enum getterHistoryExcludesCombineRxWrapperWeak {
    /// @mockable(getter: all = true; combine: pubPublisher = @Published wrapped; rx: streamObs = PublishSubject; modifiers: weakRef = weak; dynRef = dynamic)
    public protocol GHExcludes {
        var wrapped: Int { get set }
        var pubPublisher: AnyPublisher<Int, Never> { get }
        var streamObs: Observable<Int> { get }
        var weakRef: AnyObject? { get }
        var dynRef: AnyObject? { get }
        var tracked: Int { get }
    }

    @Fixture(imports: ["Combine"]) enum expected {
        public class GHExcludesMock: GHExcludes {
            public init() { }
            public init(wrapped: Int = 0, streamObs: Observable<Int> = PublishSubject<Int>(), weakRef: AnyObject? = nil, dynRef: AnyObject? = nil, tracked: Int = 0) {
                self.wrapped = wrapped
                self.streamObs = streamObs
                self.weakRef = weakRef
                self.dynRef = dynRef
                self._tracked = tracked
            }
            public private(set) var wrappedSetCallCount = 0
            @Published public var wrapped: Int = 0 { didSet { wrappedSetCallCount += 1 } }
            public var pubPublisher: AnyPublisher<Int, Never> { return self.$wrapped.setFailureType(to: Never.self).eraseToAnyPublisher() }
            public private(set) var streamObsSubjectSetCallCount = 0
            var _streamObs: Observable<Int>? { didSet { streamObsSubjectSetCallCount += 1 } }
            public var streamObsSubject = PublishSubject<Int>() { didSet { streamObsSubjectSetCallCount += 1 } }
            public var streamObs: Observable<Int> {
                get { return _streamObs ?? streamObsSubject }
                set { if let val = newValue as? PublishSubject<Int> { streamObsSubject = val } else { _streamObs = newValue } }
            }
            public weak var weakRef: AnyObject? = nil
            public dynamic var dynRef: AnyObject? = nil
            public private(set) var trackedGetCallCount = 0
            private var _tracked: Int = 0
            public var tracked: Int {
                get { trackedGetCallCount += 1; return _tracked }
                set { _tracked = newValue }
            }
        }
    }
}

// A direct `BehaviorSubject<…>` is NOT intercepted by the Rx template, so it stays eligible and IS tracked.
@Fixture enum getterHistoryRxSubjectEligible {
    /// @mockable(getter: subj = true)
    public protocol GHRxSubject {
        var subj: BehaviorSubject<Bool> { get }
    }

    @Fixture enum expected {
        public class GHRxSubjectMock: GHRxSubject {
            public init() { }
            public init(subj: BehaviorSubject<Bool>) {
                self._subj = subj
            }
            public private(set) var subjGetCallCount = 0
            private var _subj: BehaviorSubject<Bool>!
            public var subj: BehaviorSubject<Bool> {
                get { subjGetCallCount += 1; return _subj }
                set { _subj = newValue }
            }
        }
    }
}

// Actor mock: the counter is a plain (actor-isolated) property — no MockoloMutex.
@Fixture enum getterHistoryActor {
    /// @mockable
    public protocol GHActor: Actor {
        var state: Int { get }
    }

    @Fixture enum expected {
        public actor GHActorMock: GHActor {
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

// Re-ingesting an already-generated mock that contains `valueGetCallCount`: the merger must key it
// back to `value` (not `valueGet`) so the child's inherited `value` dedups cleanly (no redeclaration).
@Fixture enum getterHistoryProcessedMockMerge {
    public protocol GHParent {
        var value: Int { get }
    }
    /// @mockable
    public protocol GHChild: GHParent {
        var value: Int { get }
    }

    @Fixture enum parent {
        public class GHParentMock: GHParent {
            public init() { }
            public private(set) var valueGetCallCount = 0
            private var _value: Int = 0
            public var value: Int {
                get { valueGetCallCount += 1; return _value }
                set { _value = newValue }
            }
        }
    }

    typealias GHParentMock = parent.GHParentMock

    @Fixture enum expected {
        public class GHChildMock: GHChild {
            public init() { }
            public init(value: Int = 0) {
                self._value = value
            }
            public private(set) var valueGetCallCount = 0
            private var _value: Int = 0
            public var value: Int {
                get { valueGetCallCount += 1; return _value }
                set { _value = newValue }
            }
        }
    }
}

// A tracked optional-closure get-only prop emits `_handler`; an explicit `init(handler:)` whose
// param is not an init candidate would also emit one. Confirms exactly one `_handler` (dedup).
@Fixture enum getterHistoryOptionalClosureInitCollision {
    /// @mockable(getter: handler = true)
    public protocol GHClosure {
        var handler: (() -> Void)? { get }
        init(handler: (() -> Void)?)
    }

    @Fixture enum expected {
        public class GHClosureMock: GHClosure {
            public init() { }
            required public init(handler: (() -> Void)? = nil) {
                self._handler = handler
            }
            public private(set) var handlerGetCallCount = 0
            private var _handler: (() -> Void)? = nil
            public var handler: (() -> Void)? {
                get { handlerGetCallCount += 1; return _handler }
                set { _handler = newValue }
            }
        }
    }
}

// Existential `any` and namespaced types render valid backing stores when tracked.
@Fixture enum getterHistoryEdgeTypes {
    /// @mockable(getter: all = true)
    public protocol GHTypes {
        var anyVal: any Sequence { get }
        var nsVal: Swift.Int { get }
    }

    @Fixture enum expected {
        public class GHTypesMock: GHTypes {
            public init() { }
            public init(anyVal: any Sequence, nsVal: Swift.Int) {
                self._anyVal = anyVal
                self._nsVal = nsVal
            }
            public private(set) var anyValGetCallCount = 0
            private var _anyVal: (any Sequence)!
            public var anyVal: any Sequence {
                get { anyValGetCallCount += 1; return _anyVal }
                set { _anyVal = newValue }
            }
            public private(set) var nsValGetCallCount = 0
            private var _nsVal: Swift.Int!
            public var nsVal: Swift.Int {
                get { nsValGetCallCount += 1; return _nsVal }
                set { _nsVal = newValue }
            }
        }
    }
}
