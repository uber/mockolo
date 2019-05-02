import MockoloFramework


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
}
"""

let genericFuncMock = """
import Foundation

class GenericFuncMock: GenericFunc {
    
    init() {
        
    }
    var containsGenericCallCount = 0
    var containsGenericHandler: ((Any, Any) -> (Any))?
    func containsGeneric<T: StringProtocol, U: ExpressibleByIntegerLiteral>(arg1: T, arg2: @escaping (U) -> ()) -> ((T) -> (U)) {
        containsGenericCallCount += 1
        if let containsGenericHandler = containsGenericHandler {
            return containsGenericHandler(arg1, arg2) as! ((T) -> (U))
        }
        fatalError("containsGenericHandler returns can't have a default value thus its handler must be set")
    }
    var sendEventsCallCount = 0
    var sendEventsHandler: (([SomeEvent], Any, Bool, Any) -> ())?
    func sendEvents<T>(events: [SomeEvent], value: T, once: Bool, closure: @escaping (T) -> ())  {
        sendEventsCallCount += 1
        if let sendEventsHandler = sendEventsHandler {
            return sendEventsHandler(events, value, once, closure)
        }
        
    }
    var pushCallCount = 0
    var pushHandler: ((Request, StatusCode.Type?) -> (Any))?
    func push<T: Body>(_ request: Request, statusErrorCodeType: StatusCode.Type?) -> Observable<T> {
        pushCallCount += 1
        if let pushHandler = pushHandler {
            return pushHandler(request, statusErrorCodeType) as! Observable<T>
        }
        return Observable.empty()
    }
    var fetchCallCount = 0
    var fetchHandler: ((Request, StatusCode.Type?) -> (Any))?
    func fetch<T: Body>(_ request: Request, statusErrorCodeType: StatusCode.Type?) -> Observable<T> {
        fetchCallCount += 1
        if let fetchHandler = fetchHandler {
            return fetchHandler(request, statusErrorCodeType) as! Observable<T>
        }
        return Observable.empty()
    }
    var tellCallCount = 0
    var tellHandler: ((ResponseType, Any) -> (Disposable))?
    func tell<BodyType: Body>(_ type: ResponseType, with handler: @escaping (BodyType) -> ()) -> Disposable {
        tellCallCount += 1
        if let tellHandler = tellHandler {
            return tellHandler(type, handler)
        }
        fatalError("tellHandler returns can't have a default value thus its handler must be set")
    }
    var tellTypeCallCount = 0
    var tellTypeHandler: ((ResponseType, Any) -> (Disposable))?
    func tell<BodyType: AnotherBody>(_ type: ResponseType, with handler: @escaping (BodyType) -> ()) -> Disposable {
        tellTypeCallCount += 1
        if let tellTypeHandler = tellTypeHandler {
            return tellTypeHandler(type, handler)
        }
        fatalError("tellTypeHandler returns can't have a default value thus its handler must be set")
    }
}
"""
