import MockoloFramework

let argumentsHistoryWithAnnotation = """
/// \(String.mockAnnotation)(history: fooFunc = true)
protocol Foo {
    func fooFunc(val: Int)
    func barFunc(val: Int)
}
"""

let argumentsHistoryWithAnnotationAllFuncCaseMock = """
class FooMock: Foo {
    init() { }

    var fooFuncCallCount = 0
    var fooFuncValues = [Int]()
    var fooFuncHandler: ((Int) -> ())?
    func fooFunc(val: Int) {
        fooFuncCallCount += 1
        fooFuncValues.append(val)

        if let fooFuncHandler = fooFuncHandler {
            fooFuncHandler(val)
        }
    }

    var barFuncCallCount = 0
    var barFuncValues = [Int]()
    var barFuncHandler: ((Int) -> ())?
    func barFunc(val: Int) {
        barFuncCallCount += 1
        barFuncValues.append(val)

        if let barFuncHandler = barFuncHandler {
            barFuncHandler(val)
        }
    }
}
"""

let argumentsHistoryWithAnnotationNotAllFuncCaseMock = """
class FooMock: Foo {
    init() { }

    var fooFuncCallCount = 0
    var fooFuncValues = [Int]()
    var fooFuncHandler: ((Int) -> ())?
    func fooFunc(val: Int) {
        fooFuncCallCount += 1
        fooFuncValues.append(val)

        if let fooFuncHandler = fooFuncHandler {
            fooFuncHandler(val)
        }
    }

    var barFuncCallCount = 0
    var barFuncHandler: ((Int) -> ())?
    func barFunc(val: Int) {
        barFuncCallCount += 1

        if let barFuncHandler = barFuncHandler {
            barFuncHandler(val)
        }
    }
}
"""

let argumentsHistorySimpleCase = """
/// \(String.mockAnnotation)
protocol Foo {
   func fooFunc()
   func barFunc(val: Int)
   func bazFunc(_ val: Int)
   func quxFunc(val: Int) -> String
   func quuxFunc(val1: String, val2: Float)
}
"""

let argumentsHistorySimpleCaseMock = """
class FooMock: Foo {
    init() { }

    var fooFuncCallCount = 0
    var fooFuncHandler: (() -> ())?
    func fooFunc() {
        fooFuncCallCount += 1
        
        if let fooFuncHandler = fooFuncHandler {
            fooFuncHandler()
        }
    }

    var barFuncCallCount = 0
    var barFuncValues = [Int]()
    var barFuncHandler: ((Int) -> ())?
    func barFunc(val: Int) {
        barFuncCallCount += 1
        barFuncValues.append(val)

        if let barFuncHandler = barFuncHandler {
            barFuncHandler(val)
        }
    }

    var bazFuncCallCount = 0
    var bazFuncValues = [Int]()
    var bazFuncHandler: ((Int) -> ())?
    func bazFunc(_ val: Int) {
        bazFuncCallCount += 1
        bazFuncValues.append(val)

        if let bazFuncHandler = bazFuncHandler {
            bazFuncHandler(val)
        }
    }

    var quxFuncCallCount = 0
    var quxFuncValues = [Int]()
    var quxFuncHandler: ((Int) -> (String))?
    func quxFunc(val: Int) -> String {
        quxFuncCallCount += 1
        quxFuncValues.append(val)

        if let quxFuncHandler = quxFuncHandler {
            return quxFuncHandler(val)
        }
        return ""
    }

    var quuxFuncCallCount = 0
    var quuxFuncValues = [(String, Float)]()
    var quuxFuncHandler: ((String, Float) -> ())?
    func quuxFunc(val1: String, val2: Float) {
        quuxFuncCallCount += 1
        quuxFuncValues.append((val1, val2))

        if let quuxFuncHandler = quuxFuncHandler {
            quuxFuncHandler(val1, val2)
        }
    }
}
"""

let argumentsHistoryTupleCase = """
/// \(String.mockAnnotation)(history: fooFunc = true)
protocol Foo {
    func fooFunc(val: (Int, String))
    func barFunc(val1: (bar1: Int, String), val2: (bar3: Int, bar4: String))
}
"""

let argumentsHistoryTupleCaseMock = """
class FooMock: Foo {
    init() { }

    var fooFuncCallCount = 0
    var fooFuncValues = [(Int, String)]()
    var fooFuncHandler: (((Int, String)) -> ())?
    func fooFunc(val: (Int, String)) {
        fooFuncCallCount += 1
        fooFuncValues.append(val)

        if let fooFuncHandler = fooFuncHandler {
            fooFuncHandler(val)
        }
    }

    var barFuncCallCount = 0
    var barFuncValues = [((bar1: Int, String), (bar3: Int, bar4: String))]()
    var barFuncHandler: (((bar1: Int, String), (bar3: Int, bar4: String)) -> ())?
    func barFunc(val1: (bar1: Int, String), val2: (bar3: Int, bar4: String)) {
        barFuncCallCount += 1
        barFuncValues.append((val1, val2))

        if let barFuncHandler = barFuncHandler {
            barFuncHandler(val1, val2)
        }
    }
}
"""

let argumentsHistoryInoutCase = """
/// \(String.mockAnnotation)
protocol Foo {
    func fooFunc(val: inout Int)
    func barFunc(into val: inout Int)
}
"""

let argumentsHistoryInoutCaseMock = """
class FooMock: Foo {
    init() { }

    var fooFuncCallCount = 0
    var fooFuncValues = [Int]()
    var fooFuncHandler: ((inout Int) -> ())?
    func fooFunc(val: inout Int) {
        fooFuncCallCount += 1
        fooFuncValues.append(val)

        if let fooFuncHandler = fooFuncHandler {
            fooFuncHandler(&val)
        }
    }

    var barFuncCallCount = 0
    var barFuncValues = [Int]()
    var barFuncHandler: ((inout Int) -> ())?
    func barFunc(into val: inout Int) {
        barFuncCallCount += 1
        barFuncValues.append(val)

        if let barFuncHandler = barFuncHandler {
        barFuncHandler(&val)
        }
    }
}
"""

let argumentsHistoryHandlerCase = """
/// \(String.mockAnnotation)
protocol Foo {
    func fooFunc(handler: () -> Int)
    func barFunc(val: Int, handler: (String) -> Void)
}
"""

let argumentsHistoryHandlerCaseMock = """
class FooMock: Foo {
    init() { }

    var fooFuncCallCount = 0
    var fooFuncHandler: ((() -> Int) -> ())?
    func fooFunc(handler: () -> Int) {
        fooFuncCallCount += 1

        if let fooFuncHandler = fooFuncHandler {
            fooFuncHandler(handler)
        }
    }

    var barFuncCallCount = 0
    var barFuncValues = [Int]()
    var barFuncHandler: ((Int, (String) -> Void) -> ())?
    func barFunc(val: Int, handler: (String) -> Void) {
        barFuncCallCount += 1
        barFuncValues.append(val)

        if let barFuncHandler = barFuncHandler {
            barFuncHandler(val, handler)
        }
    }
}
"""
