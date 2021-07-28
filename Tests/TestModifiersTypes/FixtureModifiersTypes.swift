import MockoloFramework

let modifiersTypesWithWeakAnnotation = """
/// \(String.mockAnnotation)(modifiers: listener = weak)
protocol Foo {
    var listener: AnyObject? { get }
    func barFunc(val: [Int])
    func bazFunc(arg: String, other: Float)
}
"""

let modifiersTypesWithWeakAnnotationMock = """
class FooMock: Foo {
    init() { }
    init(listener: AnyObject? = nil) {
        self.listener = listener
    }


    private(set) var listenerSetCallCount = 0
    weak var listener: AnyObject? = nil { didSet { listenerSetCallCount += 1 } }

    private(set) var barFuncCallCount = 0
    var barFuncHandler: (([Int]) -> ())?
    func barFunc(val: [Int])  {
        barFuncCallCount += 1
        if let barFuncHandler = barFuncHandler {
            barFuncHandler(val)
        }

    }

    private(set) var bazFuncCallCount = 0
    var bazFuncHandler: ((String, Float) -> ())?
    func bazFunc(arg: String, other: Float)  {
        bazFuncCallCount += 1
        if let bazFuncHandler = bazFuncHandler {
            bazFuncHandler(arg, other)
        }

    }
}

"""

let modifiersTypesWithDynamicAnnotation = """
/// \(String.mockAnnotation)(modifiers: listener = dynamic)
protocol Foo {
    var listener: AnyObject? { get }
    func barFunc(val: [Int])
    func bazFunc(arg: String, other: Float)
}
"""

let modifiersTypesWithDynamicAnnotationMock = """
class FooMock: Foo {
    init() { }
    init(listener: AnyObject? = nil) {
        self.listener = listener
    }


    private(set) var listenerSetCallCount = 0
    dynamic var listener: AnyObject? = nil { didSet { listenerSetCallCount += 1 } }

    private(set) var barFuncCallCount = 0
    var barFuncHandler: (([Int]) -> ())?
    func barFunc(val: [Int])  {
        barFuncCallCount += 1
        if let barFuncHandler = barFuncHandler {
            barFuncHandler(val)
        }

    }

    private(set) var bazFuncCallCount = 0
    var bazFuncHandler: ((String, Float) -> ())?
    func bazFunc(arg: String, other: Float)  {
        bazFuncCallCount += 1
        if let bazFuncHandler = bazFuncHandler {
            bazFuncHandler(arg, other)
        }

    }
}

"""

let modifiersTypesWithDynamicFuncAnnotation = """
/// \(String.mockAnnotation)(modifiers: barFunc = dynamic)
protocol Foo {
    var listener: AnyObject? { get }
    func barFunc(val: [Int])
    func bazFunc(arg: String, other: Float)
}
"""

let modifiersTypesWithDynamicFuncAnnotationMock = """
class FooMock: Foo {
    init() { }
    init(listener: AnyObject? = nil) {
        self.listener = listener
    }


    private(set) var listenerSetCallCount = 0
    var listener: AnyObject? = nil { didSet { listenerSetCallCount += 1 } }

    private(set) var barFuncCallCount = 0
    var barFuncHandler: (([Int]) -> ())?
    dynamic func barFunc(val: [Int])  {
        barFuncCallCount += 1
        if let barFuncHandler = barFuncHandler {
            barFuncHandler(val)
        }

    }

    private(set) var bazFuncCallCount = 0
    var bazFuncHandler: ((String, Float) -> ())?
    func bazFunc(arg: String, other: Float)  {
        bazFuncCallCount += 1
        if let bazFuncHandler = bazFuncHandler {
            bazFuncHandler(arg, other)
        }

    }
}

"""
