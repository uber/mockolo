import MockoloFramework

let genericOptionalType = """
/// \(String.mockAnnotation)
public protocol GenericProtocol {
    func nonOptional<T>() -> T
    func optional<T>() -> T?
}
"""

let genericOptionalTypeMock = """


public class GenericProtocolMock: GenericProtocol {
    public init() { }


    public private(set) var nonOptionalCallCount = 0
    public var nonOptionalHandler: (() -> Any)?
    public func nonOptional<T>() -> T {
        nonOptionalCallCount += 1
        if let nonOptionalHandler = nonOptionalHandler {
            return nonOptionalHandler() as! T
        }
        fatalError("nonOptionalHandler returns can't have a default value thus its handler must be set")
    }

    public private(set) var optionalCallCount = 0
    public var optionalHandler: (() -> Any?)?
    public func optional<T>() -> T? {
        optionalCallCount += 1
        if let optionalHandler = optionalHandler {
            return optionalHandler() as? T
        }
        return nil
    }
}


"""

let genericFunc = """
import Foundation

/// \(String.mockAnnotation)
protocol GenericFunc {
    func containsGeneric<T: StringProtocol, U: ExpressibleByIntegerLiteral>(arg1: T, arg2: @escaping (U) -> ()) -> ((T) -> (U))
    func sendEvents<T>(events: [SomeEvent], value: T, once: Bool, closure: @escaping (T) -> ())
    func push<T: Body>(_ request: Request, statusErrorCodeType: StatusCode.Type?) -> Observable<T>
    func fetch<T: Body>(_ request: Request, statusErrorCodeType: StatusCode.Type?) -> Observable<T>
    func tell<BodyType: Body>(_ type: ResponseType, with handler: @escaping (BodyType) -> ()) -> Disposable
    func tell<BodyType: AnotherBody>(_ type: ResponseType, with handler: @escaping (BodyType) -> ()) -> Disposable
    func pull<T>(events: [SomeEvent], value: T, once: Bool, closure: @escaping (T?) -> ())
    func pull<U: ObservableType>(events: [SomeEvent], until: U?, closure: @escaping () -> ())
    func optionalPull<T>(events: [SomeEvent], value: T, once: Bool, closure: ((T?) -> ())?)
    func add<T: FixedWidthInteger>(n1: T, n2: T?)
    func add<T: Sequence> (a: T?, b: T?)
    func add<T: Collection> (a: T, b: T)
}
"""

let genericFuncMock =
"""

import Foundation


class GenericFuncMock: GenericFunc {
    init() { }


    private(set) var containsGenericCallCount = 0
    var containsGenericHandler: ((Any, Any) -> Any)?
    func containsGeneric<T: StringProtocol, U: ExpressibleByIntegerLiteral>(arg1: T, arg2: @escaping (U) -> ()) -> ((T) -> (U)) {
        containsGenericCallCount += 1
        if let containsGenericHandler = containsGenericHandler {
            return containsGenericHandler(arg1, arg2) as! ((T) -> (U))
        }
        fatalError("containsGenericHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var sendEventsCallCount = 0
    var sendEventsHandler: (([SomeEvent], Any, Bool, Any) -> ())?
    func sendEvents<T>(events: [SomeEvent], value: T, once: Bool, closure: @escaping (T) -> ()) {
        sendEventsCallCount += 1
        if let sendEventsHandler = sendEventsHandler {
            sendEventsHandler(events, value, once, closure)
        }
        
    }

    private(set) var pushCallCount = 0
    var pushHandler: ((Request, StatusCode.Type?) -> Any)?
    func push<T: Body>(_ request: Request, statusErrorCodeType: StatusCode.Type?) -> Observable<T> {
        pushCallCount += 1
        if let pushHandler = pushHandler {
            return pushHandler(request, statusErrorCodeType) as! Observable<T>
        }
        return Observable<T>.empty()
    }

    private(set) var fetchCallCount = 0
    var fetchHandler: ((Request, StatusCode.Type?) -> Any)?
    func fetch<T: Body>(_ request: Request, statusErrorCodeType: StatusCode.Type?) -> Observable<T> {
        fetchCallCount += 1
        if let fetchHandler = fetchHandler {
            return fetchHandler(request, statusErrorCodeType) as! Observable<T>
        }
        return Observable<T>.empty()
    }

    private(set) var tellCallCount = 0
    var tellHandler: ((ResponseType, Any) -> Disposable)?
    func tell<BodyType: Body>(_ type: ResponseType, with handler: @escaping (BodyType) -> ()) -> Disposable {
        tellCallCount += 1
        if let tellHandler = tellHandler {
            return tellHandler(type, handler)
        }
        fatalError("tellHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var tellTypeCallCount = 0
    var tellTypeHandler: ((ResponseType, Any) -> Disposable)?
    func tell<BodyType: AnotherBody>(_ type: ResponseType, with handler: @escaping (BodyType) -> ()) -> Disposable {
        tellTypeCallCount += 1
        if let tellTypeHandler = tellTypeHandler {
            return tellTypeHandler(type, handler)
        }
        fatalError("tellTypeHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var pullCallCount = 0
    var pullHandler: (([SomeEvent], Any, Bool, Any) -> ())?
    func pull<T>(events: [SomeEvent], value: T, once: Bool, closure: @escaping (T?) -> ()) {
        pullCallCount += 1
        if let pullHandler = pullHandler {
            pullHandler(events, value, once, closure)
        }
        
    }

    private(set) var pullEventsCallCount = 0
    var pullEventsHandler: (([SomeEvent], Any?, @escaping () -> ()) -> ())?
    func pull<U: ObservableType>(events: [SomeEvent], until: U?, closure: @escaping () -> ()) {
        pullEventsCallCount += 1
        if let pullEventsHandler = pullEventsHandler {
            pullEventsHandler(events, until, closure)
        }
        
    }

    private(set) var optionalPullCallCount = 0
    var optionalPullHandler: (([SomeEvent], Any, Bool, ((Any?) -> ())?) -> ())?
    func optionalPull<T>(events: [SomeEvent], value: T, once: Bool, closure: ((T?) -> ())?) {
        optionalPullCallCount += 1
        if let optionalPullHandler = optionalPullHandler {
            optionalPullHandler(events, value, once, closure as? ((Any?) -> ()))
        }
        
    }

    private(set) var addCallCount = 0
    var addHandler: ((Any, Any?) -> ())?
    func add<T: FixedWidthInteger>(n1: T, n2: T?) {
        addCallCount += 1
        if let addHandler = addHandler {
            addHandler(n1, n2)
        }
        
    }

    private(set) var addACallCount = 0
    var addAHandler: ((Any?, Any?) -> ())?
    func add<T: Sequence>(a: T?, b: T?) {
        addACallCount += 1
        if let addAHandler = addAHandler {
            addAHandler(a, b)
        }
        
    }

    private(set) var addABCallCount = 0
    var addABHandler: ((Any, Any) -> ())?
    func add<T: Collection>(a: T, b: T) {
        addABCallCount += 1
        if let addABHandler = addABHandler {
            addABHandler(a, b)
        }
        
    }
}


"""


let funcWhereClause = """

protocol Parsable {
    //  ...
}
protocol APITarget {
    associatedtype ResultType

    // ...
}

/// @mockable
protocol Networking {
    func request<T>(_ target: T) -> T.ResultType where T: APITarget & Parsable
}
"""

let funcWhereClauseMock = """

class NetworkingMock: Networking {
    init() { }


    private(set) var requestCallCount = 0
    var requestHandler: ((Any) -> Any)?
    func request<T>(_ target: T) -> T.ResultType where T: APITarget & Parsable {
        requestCallCount += 1
        if let requestHandler = requestHandler {
            return requestHandler(target) as! T.ResultType
        }
        fatalError("requestHandler returns can't have a default value thus its handler must be set")
    }
}
"""

let funcDuplicateSignatureDifferentWhereClause = """
/// \(String.mockAnnotation)
protocol Storing {
   func connect<T>(adapter: T) where T: Adapter
   func connect<T>(adapter: T) where T: KeyedAdapter
   func connect<T>(adapter: T) where T: KeyedAdapter2
   func connect<T>(adapter: T) where T: KeyedAdapter3
}
"""

let funcDuplicateSignatureDifferentWhereClauseMock = """
class StoringMock: Storing {
    init() { }


    private(set) var connectCallCount = 0
    var connectHandler: ((Any) -> ())?
    func connect<T>(adapter: T) where T: Adapter {
        connectCallCount += 1
        if let connectHandler = connectHandler {
            connectHandler(adapter)
        }
    }

    private(set) var connectAdapterCallCount = 0
    var connectAdapterHandler: ((Any) -> ())?
    func connect<T>(adapter: T) where T: KeyedAdapter {
        connectAdapterCallCount += 1
        if let connectAdapterHandler = connectAdapterHandler {
            connectAdapterHandler(adapter)
        }
    }

    private(set) var connectAdapterTCallCount = 0
    var connectAdapterTHandler: ((Any) -> ())?
    func connect<T>(adapter: T) where T: KeyedAdapter2 {
        connectAdapterTCallCount += 1
        if let connectAdapterTHandler = connectAdapterTHandler {
            connectAdapterTHandler(adapter)
        }
    }

    private(set) var connectAdapterTTKeyedAdapter3CallCount = 0
    var connectAdapterTTKeyedAdapter3Handler: ((Any) -> ())?
    func connect<T>(adapter: T) where T: KeyedAdapter3 {
        connectAdapterTTKeyedAdapter3CallCount += 1
        if let connectAdapterTTKeyedAdapter3Handler = connectAdapterTTKeyedAdapter3Handler {
            connectAdapterTTKeyedAdapter3Handler(adapter)
        }
    }
}
"""

let funcDuplicateSignatureDifferentWhereClauseEquality = """
/// \(String.mockAnnotation)
protocol Storing<S: Sequence> {
   func connect<T>(adapter: T) where T: Adapter, T.Element == S.Element
   func connect<T>(adapter: T) where T: KeyedAdapter, T.Element == S.Element
   func connect<T>(adapter: T) where T: KeyedAdapter2, T.Element == S.Element
   func connect<T>(adapter: T) where T: KeyedAdapter3, T.Element == S.Element
}
"""

let funcDuplicateSignatureDifferentWhereClauseEqualityMock = """
class StoringMock: Storing {
    init() { }


    private(set) var connectCallCount = 0
    var connectHandler: ((Any) -> ())?
    func connect<T>(adapter: T) where T: Adapter, T.Element == S.Element {
        connectCallCount += 1
        if let connectHandler = connectHandler {
            connectHandler(adapter)
        }
    }

    private(set) var connectAdapterCallCount = 0
    var connectAdapterHandler: ((Any) -> ())?
    func connect<T>(adapter: T) where T: KeyedAdapter, T.Element == S.Element {
        connectAdapterCallCount += 1
        if let connectAdapterHandler = connectAdapterHandler {
            connectAdapterHandler(adapter)
        }
    }

    private(set) var connectAdapterTCallCount = 0
    var connectAdapterTHandler: ((Any) -> ())?
    func connect<T>(adapter: T) where T: KeyedAdapter2, T.Element == S.Element {
        connectAdapterTCallCount += 1
        if let connectAdapterTHandler = connectAdapterTHandler {
            connectAdapterTHandler(adapter)
        }
    }

    private(set) var connectAdapterTTKeyedAdapter3TElementSElementCallCount = 0
    var connectAdapterTTKeyedAdapter3TElementSElementHandler: ((Any) -> ())?
    func connect<T>(adapter: T) where T: KeyedAdapter3, T.Element == S.Element {
        connectAdapterTTKeyedAdapter3TElementSElementCallCount += 1
        if let connectAdapterTTKeyedAdapter3TElementSElementHandler = connectAdapterTTKeyedAdapter3TElementSElementHandler {
            connectAdapterTTKeyedAdapter3TElementSElementHandler(adapter)
        }
    }
}
"""
