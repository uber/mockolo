import SwiftMockGenCore


let genericFunc = """
import Foundation


/// \(String.mockAnnotation)
protocol GenericFunc {
func containsGeneric<T: StringProtocol, U: ExpressibleByIntegerLiteral>(arg1: T, arg2: @escaping (U) -> ()) -> ((T) -> (U))
func confineToViewEvents<T>(viewEvents: [ViewControllerLifecycleEvent], value: T, once: Bool, closure: @escaping (T) -> ())
func enqueue<T: ResponseBody>(_ request: HTTPRequest, statusErrorCodeType: StatusErrorCodeConvertible.Type?) -> Observable<T>
func dequeue<T: ResponseBody>(_ request: HTTPRequest, statusErrorCodeType: StatusErrorCodeConvertible.Type?) -> Observable<T>
func registerMessage<ModelType: ResponseBody>(_ messageType: ResponseMessageType, withHandler handler: @escaping (ModelType) -> ()) -> Disposable
func registerMessage<ModelType: RealtimeDecodable>(_ messageType: ResponseMessageType, withHandler handler: @escaping (ModelType) -> ()) -> Disposable

}
"""

let genericFuncMock = """
import Foundation

class GenericFuncMock: GenericFunc {
    init() {
        
    }
    
    var containsGenericArg1CallCount = 0
    var containsGenericArg1Handler: ((Any, Any) -> (Any))?
    func containsGeneric<T: StringProtocol, U: ExpressibleByIntegerLiteral>(arg1: T, arg2: @escaping (U) -> ()) -> ((T) -> (U)) {
        containsGenericArg1CallCount += 1
        if let containsGenericArg1Handler = containsGenericArg1Handler {
            return containsGenericArg1Handler(arg1, arg2) as! ((T) -> (U))
        }
        fatalError("containsGenericArg1Handler returns can't have a default value thus its handler must be set")
    }
    var confineToViewEventsValueCallCount = 0
    var confineToViewEventsValueHandler: (([ViewControllerLifecycleEvent], Any, Bool, Any) -> ())?
    func confineToViewEvents<T>(viewEvents: [ViewControllerLifecycleEvent], value: T, once: Bool, closure: @escaping (T) -> ())  {
        confineToViewEventsValueCallCount += 1
        if let confineToViewEventsValueHandler = confineToViewEventsValueHandler {
            return confineToViewEventsValueHandler(viewEvents, value, once, closure)
        }
        
    }
    var enqueueRequestCallCount = 0
    var enqueueRequestHandler: ((HTTPRequest, StatusErrorCodeConvertible.Type?) -> (Any))?
    func enqueue<T: ResponseBody>(_ request: HTTPRequest, statusErrorCodeType: StatusErrorCodeConvertible.Type?) -> Observable<T> {
        enqueueRequestCallCount += 1
        if let enqueueRequestHandler = enqueueRequestHandler {
            return enqueueRequestHandler(request, statusErrorCodeType) as! Observable<T>
        }
        fatalError("enqueueRequestHandler returns can't have a default value thus its handler must be set")
    }
    var dequeueRequestCallCount = 0
    var dequeueRequestHandler: ((HTTPRequest, StatusErrorCodeConvertible.Type?) -> (Any))?
    func dequeue<T: ResponseBody>(_ request: HTTPRequest, statusErrorCodeType: StatusErrorCodeConvertible.Type?) -> Observable<T> {
        dequeueRequestCallCount += 1
        if let dequeueRequestHandler = dequeueRequestHandler {
            return dequeueRequestHandler(request, statusErrorCodeType) as! Observable<T>
        }
        fatalError("dequeueRequestHandler returns can't have a default value thus its handler must be set")
    }
    var registerMessageCallCount = 0
    var registerMessageHandler: ((ResponseMessageType, Any) -> (Disposable))?
    func registerMessage<ModelType: ResponseBody>(_ messageType: ResponseMessageType, withHandler handler: @escaping (ModelType) -> ()) -> Disposable {
        registerMessageCallCount += 1
        if let registerMessageHandler = registerMessageHandler {
            return registerMessageHandler(messageType, handler)
        }
        fatalError("registerMessageHandler returns can't have a default value thus its handler must be set")
    }
    var registerMessageMessageTypeWithHandlerCallCount = 0
    var registerMessageMessageTypeWithHandlerHandler: ((ResponseMessageType, Any) -> (Disposable))?
    func registerMessage<ModelType: RealtimeDecodable>(_ messageType: ResponseMessageType, withHandler handler: @escaping (ModelType) -> ()) -> Disposable {
        registerMessageMessageTypeWithHandlerCallCount += 1
        if let registerMessageMessageTypeWithHandlerHandler = registerMessageMessageTypeWithHandlerHandler {
            return registerMessageMessageTypeWithHandlerHandler(messageType, handler)
        }
        fatalError("registerMessageMessageTypeWithHandlerHandler returns can't have a default value thus its handler must be set")
    }
}
"""
