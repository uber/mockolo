let existentialAny = """
/// \(String.mockAnnotation)
protocol ExistentialAny {
    var foo: P { get }
    var bar: any R<Int> { get }
    var baz: any P & Q { get }
    var qux: (any P) -> any P { get }
}
"""

let existentialAnyMock =
"""
class ExistentialAnyMock: ExistentialAny {
    init() { }
    init(foo: P, bar: any R<Int>, baz: any P & Q, qux: @escaping (any P) -> any P) {
        self._foo = foo
        self._bar = bar
        self._baz = baz
        self._qux = qux
    }


    private var _foo: P!
    var foo: P {
        get { return _foo }
        set { _foo = newValue }
    }

    private var _bar: (any R<Int>)!
    var bar: any R<Int> {
        get { return _bar }
        set { _bar = newValue }
    }

    private var _baz: (any P & Q)!
    var baz: any P & Q {
        get { return _baz }
        set { _baz = newValue }
    }

    private var _qux: ((any P) -> any P)!
    var qux: (any P) -> any P {
        get { return _qux }
        set { _qux = newValue }
    }
}
"""

let existentialAnyDefaultTypeMap = """
/// \(String.mockAnnotation)
protocol SomeProtocol {
}

/// \(String.mockAnnotation)
protocol UseSomeProtocol {
    func foo() -> any SomeProtocol
}
"""

let existentialAnyDefaultTypeMapMock = """
class SomeProtocolMock: SomeProtocol {
    init() { }


}

class UseSomeProtocolMock: UseSomeProtocol {
    init() { }


    private(set) var fooCallCount = 0
    var fooHandler: (()  -> (any SomeProtocol))?
    func foo()  -> any SomeProtocol {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            return fooHandler()
        }
        return SomeProtocolMock() 
    }
}
"""
