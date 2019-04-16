import SwiftMockGenCore


let overload = """
/// @CreateMock
public protocol Foo: Bar {
func encrypt(status: Int, msg: String) -> Double
}
"""

let overloadParent = """
public class BarMock: Bar {

public init() {

}

var encryptCallCount = 0
public var encryptHandler: (([String: String], ClientProtocol) -> (Observable<EncryptedData>))?
public func encrypt(data: [String: String], for client: ClientProtocol) -> Observable<EncryptedData> {
encryptCallCount += 1
if let encryptHandler = encryptHandler {
return encryptHandler(data, client)
}
return Observable.empty()
}

var encryptKeyCallCount = 0
public var encryptKeyHandler: ((Double) -> (Int))?
public func encrypt(key: Double) -> Int {
encryptKeyCallCount += 1
if let encryptKeyHandler = encryptKeyHandler {
return encryptKeyHandler(key)
}
return 0
}
}

"""

let overloadMock = """
public class FooMock: Foo {
    
    public init() {
        
    }
    var encryptStatusCallCount = 0
    public var encryptStatusHandler: ((Int, String) -> (Double))?
    public func encrypt(status: Int, msg: String) -> Double {
        encryptStatusCallCount += 1
        if let encryptStatusHandler = encryptStatusHandler {
            return encryptStatusHandler(status, msg)
        }
        return 0.0
    }
    var encryptCallCount = 0
    public var encryptHandler: (([String: String], ClientProtocol) -> (Observable<EncryptedData>))?
    public func encrypt(data: [String: String], for client: ClientProtocol) -> Observable<EncryptedData> {
        encryptCallCount += 1
        if let encryptHandler = encryptHandler {
            return encryptHandler(data, client)
        }
        return Observable.empty()
    }
    var encryptKeyCallCount = 0
    public var encryptKeyHandler: ((Double) -> (Int))?
    public func encrypt(key: Double) -> Int {
        encryptKeyCallCount += 1
        if let encryptKeyHandler = encryptKeyHandler {
            return encryptKeyHandler(key)
        }
        return 0
    }
}
"""
