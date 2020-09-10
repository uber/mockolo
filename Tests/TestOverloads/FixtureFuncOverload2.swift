import MockoloFramework


let overload2 = """
/// \(String.mockAnnotation)
public protocol Foo: Bar {
    func tell(status: Int, msg: String) -> Double
}
"""

let overloadParent2 = """
public class BarMock: Bar {
    
    
    public init() {
        
    }
    
    public private(set) var tellCallCount = 0
    public var tellHandler: (([String: String], ClientProtocol) -> (Observable<EncryptedData>))?
    public func tell(data: [String: String], for client: ClientProtocol) -> Observable<EncryptedData> {
        tellCallCount += 1
        if let tellHandler = tellHandler {
            return tellHandler(data, client)
        }
        return Observable.empty()
    }
    
    public private(set) var tellKeyCallCount = 0
    public var tellKeyHandler: ((Double) -> (Int))?
    public func tell(key: Double) -> Int {
        tellKeyCallCount += 1
        if let tellKeyHandler = tellKeyHandler {
            return tellKeyHandler(key)
        }
        return 0
    }
}


"""

let overloadMock2 =

"""

public class FooMock: Foo {
    public init() { }


    public private(set) var tellStatusCallCount = 0
    public var tellStatusHandler: ((Int, String) -> (Double))?
    public func tell(status: Int, msg: String) -> Double {
        tellStatusCallCount += 1
        if let tellStatusHandler = tellStatusHandler {
            return tellStatusHandler(status, msg)
        }
        return 0.0
    }
    
    public private(set) var tellCallCount = 0
    public var tellHandler: (([String: String], ClientProtocol) -> (Observable<EncryptedData>))?
    public func tell(data: [String: String], for client: ClientProtocol) -> Observable<EncryptedData> {
        tellCallCount += 1
        if let tellHandler = tellHandler {
            return tellHandler(data, client)
        }
        return Observable.empty()
    }
    
    public private(set) var tellKeyCallCount = 0
    public var tellKeyHandler: ((Double) -> (Int))?
    public func tell(key: Double) -> Int {
        tellKeyCallCount += 1
        if let tellKeyHandler = tellKeyHandler {
            return tellKeyHandler(key)
        }
        return 0
    }
}

"""
