let existentialAny = """
/// \(String.mockAnnotation)
protocol ExistentialAny {
    var foo: P { get }
    var bar: any R<Int> { get }
    var baz: any P & Q { get }
    var qux: (any P) -> any P { get }

    func quux() -> P
    func corge() -> any R<Int>
    func grault() -> any P & Q
    func garply() -> (any P) -> any P
}
"""

let existentialAnyMock = """
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

    private(set) var quuxCallCount = 0
    var quuxHandler: (() -> P)?
    func quux() -> P {
        quuxCallCount += 1
        if let quuxHandler = quuxHandler {
            return quuxHandler()
        }
        fatalError("quuxHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var corgeCallCount = 0
    var corgeHandler: (() -> any R<Int>)?
    func corge() -> any R<Int> {
        corgeCallCount += 1
        if let corgeHandler = corgeHandler {
            return corgeHandler()
        }
        fatalError("corgeHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var graultCallCount = 0
    var graultHandler: (() -> (any P & Q))?
    func grault() -> any P & Q {
        graultCallCount += 1
        if let graultHandler = graultHandler {
            return graultHandler()
        }
        fatalError("graultHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var garplyCallCount = 0
    var garplyHandler: (() -> ((any P) -> any P))?
    func garply() -> (any P) -> any P {
        garplyCallCount += 1
        if let garplyHandler = garplyHandler {
            return garplyHandler()
        }
        fatalError("garplyHandler returns can't have a default value thus its handler must be set")
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
    var fooHandler: (()  -> any SomeProtocol)?
    func foo()  -> any SomeProtocol {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            return fooHandler()
        }
        return SomeProtocolMock() 
    }
}
"""
