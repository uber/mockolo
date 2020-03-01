import MockoloFramework

let simpleInheritance = """
import Foundation

/// \(String.mockAnnotation)
public protocol SimpleChild: SimpleParent {
    var name: String { get set }
    func foo()
}
    
/// \(String.mockAnnotation)
public protocol SimpleParent: AnyObject {
    var number: Int { get set }
    func bar(arg: Double) -> Float?
}
    
"""
    
let simpleInheritanceMock = """

import Foundation

public class SimpleChildMock: SimpleChild {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(name: String = "", number: Int = 0) {
        self.name = name
        self.number = number
        _doneInit = true
    }
    public var nameSetCallCount = 0
    public var name: String = "" { didSet { nameSetCallCount += 1 } }
    public var fooCallCount = 0
    public var fooHandler: (() -> ())?
    public func foo()  {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            fooHandler()
        }
        
    }
    public var numberSetCallCount = 0
    public var number: Int = 0 { didSet { numberSetCallCount += 1 } }
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

public class SimpleParentMock: SimpleParent {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(number: Int = 0) {
        self.number = number
        _doneInit = true
    }
    public var numberSetCallCount = 0
    public var number: Int = 0 { didSet { numberSetCallCount += 1 } }
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
