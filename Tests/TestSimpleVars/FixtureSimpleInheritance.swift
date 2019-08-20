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
    
let simpleInheritanceMock =
"""
import Foundation


public class simpleChildMock: simpleChild {
    
    private var _doneInit = false
    public init() { _doneInit = true }
    public init(name: String = "", number: Int = 0) {
        self.name = name
        self.number = number
        _doneInit = true
    }
    
    public var nameSetCallCount = 0
    var underlyingName: String = ""
    public var name: String {
        get { return underlyingName }
        set {
            underlyingName = newValue
            if _doneInit { nameSetCallCount += 1 }
        }
    }
    public var fooCallCount = 0
    public var fooHandler: (() -> ())?
    public func foo()  {
        fooCallCount += 1
        
        if let fooHandler = fooHandler {
            fooHandler()
        }
        
    }
    public var numberSetCallCount = 0
    var underlyingNumber: Int = 0
    public var number: Int {
        get { return underlyingNumber }
        set {
            underlyingNumber = newValue
            if _doneInit { numberSetCallCount += 1 }
        }
    }
    public var barCallCount = 0
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
    
    private var _doneInit = false
    public init() { _doneInit = true }
    public init(number: Int = 0) {
        self.number = number
        _doneInit = true
    }
    
    public var numberSetCallCount = 0
    var underlyingNumber: Int = 0
    public var number: Int {
        get { return underlyingNumber }
        set {
            underlyingNumber = newValue
            if _doneInit { numberSetCallCount += 1 }
        }
    }
    public var barCallCount = 0
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
