let existentialAny = """
/// \(String.mockAnnotation)
protocol ExistentialAny {
    var foo: P { get }
    var bar: any P { get }
    var baz: any P & Q { get }
    var qux: (any P) -> any P & Q { get }
}
"""

let existentialAnyMock =
"""

class ExistentialAnyMock: ExistentialAny {
    init() { }
    init(foo: P, bar: any P, baz: any P & Q, qux: @escaping (any P) -> any P & Q) {
        self._foo = foo
        self._bar = bar
        self._baz = baz
        self._qux = qux
    }


    private(set) var fooSetCallCount = 0
    private var _foo: P!  { didSet { fooSetCallCount += 1 } }
    var foo: P {
        get { return _foo }
        set { _foo = newValue }
    }

    private(set) var barSetCallCount = 0
    private var _bar: (any P)!  { didSet { barSetCallCount += 1 } }
    var bar: any P {
        get { return _bar }
        set { _bar = newValue }
    }

    private(set) var bazSetCallCount = 0
    private var _baz: (any P & Q)!  { didSet { bazSetCallCount += 1 } }
    var baz: any P & Q {
        get { return _baz }
        set { _baz = newValue }
    }

    private(set) var quxSetCallCount = 0
    private var _qux: ((any P) -> any P & Q)!  { didSet { quxSetCallCount += 1 } }
    var qux: (any P) -> any P & Q {
        get { return _qux }
        set { _qux = newValue }
    }
}
"""
