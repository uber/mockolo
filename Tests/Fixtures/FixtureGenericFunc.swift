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
    
    var containsGenericCallCount = 0
    var containsGenericHandler: ((Any, Any) -> (Any))?
    func containsGeneric<T: StringProtocol, U: ExpressibleByIntegerLiteral>(arg1: T, arg2: @escaping (U) -> ()) -> ((T) -> (U)) {
        containsGenericCallCount += 1
        if let containsGenericHandler = containsGenericHandler {
            return containsGenericHandler(arg1, arg2) as! ((T) -> (U))
        }
        fatalError("containsGenericHandler returns can't have a default value thus its handler must be set")
    }
    var confineToViewEventsCallCount = 0
    var confineToViewEventsHandler: (([ViewControllerLifecycleEvent], Any, Bool, Any) -> ())?
    func confineToViewEvents<T>(viewEvents: [ViewControllerLifecycleEvent], value: T, once: Bool, closure: @escaping (T) -> ())  {
        confineToViewEventsCallCount += 1
        if let confineToViewEventsHandler = confineToViewEventsHandler {
            return confineToViewEventsHandler(viewEvents, value, once, closure)
        }
        
    }
    var enqueueCallCount = 0
    var enqueueHandler: ((HTTPRequest, StatusErrorCodeConvertible.Type?) -> (Any))?
    func enqueue<T: ResponseBody>(_ request: HTTPRequest, statusErrorCodeType: StatusErrorCodeConvertible.Type?) -> Observable<T> {
        enqueueCallCount += 1
        if let enqueueHandler = enqueueHandler {
            return enqueueHandler(request, statusErrorCodeType) as! Observable<T>
        }
        fatalError("enqueueHandler returns can't have a default value thus its handler must be set")
    }
    var dequeueCallCount = 0
    var dequeueHandler: ((HTTPRequest, StatusErrorCodeConvertible.Type?) -> (Any))?
    func dequeue<T: ResponseBody>(_ request: HTTPRequest, statusErrorCodeType: StatusErrorCodeConvertible.Type?) -> Observable<T> {
        dequeueCallCount += 1
        if let dequeueHandler = dequeueHandler {
            return dequeueHandler(request, statusErrorCodeType) as! Observable<T>
        }
        fatalError("dequeueHandler returns can't have a default value thus its handler must be set")
    }
    var registerMessageModelTypeResponseBodyMessageTypeHandlerCallCount = 0
    var registerMessageModelTypeResponseBodyMessageTypeHandlerHandler: ((ResponseMessageType, Any) -> (Disposable))?
    func registerMessage<ModelType: ResponseBody>(_ messageType: ResponseMessageType, withHandler handler: @escaping (ModelType) -> ()) -> Disposable {
        registerMessageModelTypeResponseBodyMessageTypeHandlerCallCount += 1
        if let registerMessageModelTypeResponseBodyMessageTypeHandlerHandler = registerMessageModelTypeResponseBodyMessageTypeHandlerHandler {
            return registerMessageModelTypeResponseBodyMessageTypeHandlerHandler(messageType, handler)
        }
        fatalError("registerMessageModelTypeResponseBodyMessageTypeHandlerHandler returns can't have a default value thus its handler must be set")
    }
    var registerMessageModelTypeRealtimeDecodableMessageTypeHandlerCallCount = 0
    var registerMessageModelTypeRealtimeDecodableMessageTypeHandlerHandler: ((ResponseMessageType, Any) -> (Disposable))?
    func registerMessage<ModelType: RealtimeDecodable>(_ messageType: ResponseMessageType, withHandler handler: @escaping (ModelType) -> ()) -> Disposable {
        registerMessageModelTypeRealtimeDecodableMessageTypeHandlerCallCount += 1
        if let registerMessageModelTypeRealtimeDecodableMessageTypeHandlerHandler = registerMessageModelTypeRealtimeDecodableMessageTypeHandlerHandler {
            return registerMessageModelTypeRealtimeDecodableMessageTypeHandlerHandler(messageType, handler)
        }
        fatalError("registerMessageModelTypeRealtimeDecodableMessageTypeHandlerHandler returns can't have a default value thus its handler must be set")
    }
}

"""

