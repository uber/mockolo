import MockoloFramework

// MARK: Simple inheritance
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
    
    
    
    public init() {  }
    public init(name: String = "", number: Int = 0) {
        self.name = name
        self.number = number
        
    }
    public private(set) var nameSetCallCount = 0
    public var name: String = "" { didSet { nameSetCallCount += 1 } }
    public private(set) var fooCallCount = 0
    public var fooHandler: (() -> ())?
    public func foo()  {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            fooHandler()
        }
        
    }
    public private(set) var numberSetCallCount = 0
    public var number: Int = 0 { didSet { numberSetCallCount += 1 } }
    public private(set) var barCallCount = 0
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
    
    
    
    public init() {  }
    public init(number: Int = 0) {
        self.number = number
        
    }
    public private(set) var numberSetCallCount = 0
    public var number: Int = 0 { didSet { numberSetCallCount += 1 } }
    public private(set) var barCallCount = 0
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

// MARK: Composition inheritance
let compositionInheritance = """

protocol FirstSwiftProtocol {
    var someBool: Bool { get }

    func doSomething()
}

protocol SecondSwiftProtocol {
    var someInt: Int { get set }

    func doSomethingElse() -> Bool
}

/// \(String.mockAnnotation)
protocol TestProtocol: FirstSwiftProtocol & SecondSwiftProtocol {
    func doSomethingSpecial()
}

"""

let compositionInheritanceMock = """
class TestProtocolMock: TestProtocol {
    init() { }
    init(someBool: Bool = false, someInt: Int = 0) {
        self.someBool = someBool
        self.someInt = someInt
    }



    var someBool: Bool = false

    private(set) var doSomethingCallCount = 0
    var doSomethingHandler: (() -> ())?
    func doSomething()  {
        doSomethingCallCount += 1
        if let doSomethingHandler = doSomethingHandler {
            doSomethingHandler()
        }

    }

    private(set) var someIntSetCallCount = 0
    var someInt: Int = 0 { didSet { someIntSetCallCount += 1 } }

    private(set) var doSomethingElseCallCount = 0
    var doSomethingElseHandler: (() -> (Bool))?
    func doSomethingElse() -> Bool {
        doSomethingElseCallCount += 1
        if let doSomethingElseHandler = doSomethingElseHandler {
            return doSomethingElseHandler()
        }
        return false
    }

    private(set) var doSomethingSpecialCallCount = 0
    var doSomethingSpecialHandler: (() -> ())?
    func doSomethingSpecial()  {
        doSomethingSpecialCallCount += 1
        if let doSomethingSpecialHandler = doSomethingSpecialHandler {
            doSomethingSpecialHandler()
        }

    }
}

"""
