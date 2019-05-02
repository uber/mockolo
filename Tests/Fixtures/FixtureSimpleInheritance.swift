import MockoloFramework

let simpleInheritance = """
import Foundation

/// \(String.mockAnnotation)
public protocol simpleChild: simpleParent {
    var name: String { get set }
    func foo()
}
    
/// \(String.mockAnnotation)
public protocol simpleParent: AnyObject {
    var number: Int { get set }
    func bar(arg: Double) -> Float?
}
    
"""
    
let simpleInheritanceMock = """
import Foundation

public class simpleChildMock: simpleChild {
    public init() {}
    public init(name: String = "", number: Int = 0) {
        self.name = name
        self.number = number
    }
    
    var nameSetCallCount = 0
    var underlyingName: String = ""
    public var name: String {
        get {
            return underlyingName
        }
        set {
            underlyingName = newValue
            nameSetCallCount += 1
        }
    }
    var fooCallCount = 0
    public var fooHandler: (() -> ())?
    public func foo()  {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            return fooHandler()
        }
        
    }
    var numberSetCallCount = 0
    var underlyingNumber: Int = 0
    public var number: Int {
        get {
            return underlyingNumber
        }
        set {
            underlyingNumber = newValue
            numberSetCallCount += 1
        }
    }
    var barCallCount = 0
    public var barHandler: ((Double) -> (Float?))?
    public func bar(arg: Double) -> Float? {
        barCallCount += 1
        if let barHandler = barHandler {
            return barHandler(arg)
        }
        return nil
    }
}

public class simpleParentMock: simpleParent {
    public init() {}
    public init(number: Int = 0) {
        self.number = number
    }
    
    var numberSetCallCount = 0
    var underlyingNumber: Int = 0
    public var number: Int {
        get {
            return underlyingNumber
        }
        set {
            underlyingNumber = newValue
            numberSetCallCount += 1
        }
    }
    var barCallCount = 0
    public var barHandler: ((Double) -> (Float?))?
    public func bar(arg: Double) -> Float? {
        barCallCount += 1
        if let barHandler = barHandler {
            return barHandler(arg)
        }
        return nil
    }
}
"""
