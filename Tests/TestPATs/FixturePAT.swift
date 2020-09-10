import MockoloFramework


let patNameCollision =
"""
/// \(String.mockAnnotation)
protocol Foo {
associatedtype T
}

/// \(String.mockAnnotation)
protocol Bar {
associatedtype T: String
}

/// \(String.mockAnnotation)(typealias: T = Hashable & Codable)
protocol Cat {
associatedtype T
}

/// \(String.mockAnnotation)
protocol Baz: Foo, Bar, Cat {
}

"""

let patNameCollisionMock =
"""


class FooMock: Foo {
    
    
    
    init() {
        
        
    }
    typealias T = Any
}

class BarMock: Bar {
    
    
    
    init() {
        
        
    }
    typealias T = String
}

class CatMock: Cat {
    
    
    
    init() {
        
        
    }
    typealias T = Hashable & Codable
}

class BazMock: Baz {
    typealias T = Any & Hashable & Codable & String
    
    
    init() {
        
        
    }
    
}
"""


let patOverride =
"""
/// \(String.mockAnnotation)(typealias: T = Any; U = Bar; R = (String, Int); S = AnyObject)
protocol Foo {
    associatedtype T
    associatedtype U: Collection where U.Element == T
    associatedtype R where Self.T == Hashable
    associatedtype S: ExpressibleByNilLiteral
    func update(x: T, y: U) -> (U, R)
}
"""

let patOverrideMock =
"""


class FooMock: Foo {
    init() { }

    typealias T = Any
    typealias U = Bar
    typealias R = (String, Int)
    typealias S = AnyObject

    private(set) var updateCallCount = 0
    var updateHandler: ((T, U) -> (U, R))?
    func update(x: T, y: U) -> (U, R) {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(x, y)
        }
        fatalError("updateHandler returns can't have a default value thus its handler must be set")
    }
}

"""

let protocolWithTypealias =
"""
/// \(String.mockAnnotation)
public protocol SomeType {
    typealias Key = String
    var key: Key { get }
}
"""

let protocolWithTypealiasMock = """

public class SomeTypeMock: SomeType {
    public init() { }
    public init(key: Key) {
        self._key = key
    }
    public typealias Key = String
    public private(set) var keySetCallCount = 0
    private var _key: Key!  { didSet { keySetCallCount += 1 } }
    public var key: Key {
        get { return _key }
        set { _key = newValue }
    }
}

"""

let patDefaultType =
"""
/// \(String.mockAnnotation)
protocol Foo {
    associatedtype T
    associatedtype U: Collection where U.Element == T
}
"""

let patDefaultTypeMock =
"""
class FooMock: Foo {
    
    
    
    init() {
        
        
    }
    typealias T = Any
    typealias U = Collection where U.Element == T
}

"""

let patPartialOverride =
"""
/// \(String.mockAnnotation)(typealias: U = AnyObject)
protocol Foo {
    associatedtype T
    associatedtype U: Collection where U.Element == T
}
"""


let patPartialOverrideMock =

"""
class FooMock: Foo {
    
    
    
    init() {
        
        
    }
    typealias T = Any
    typealias U = AnyObject
}
"""
