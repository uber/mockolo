import MockoloFramework

let o = """
/// \(String.mockAnnotation)
protocol Foo {
    func update(arg: Int) -> (String) -> Observable<Double>
}
"""

let overload4 = """
/// \(String.mockAnnotation)
protocol Foo {
func update(arg: Int, some: Float)
func update(arg: Int, some: Float) -> Int
func update(arg: Int, some: Float) -> Observable<Int>
func update(arg: Int, some: Float) -> (String) -> Observable<Double>
func update(arg: Int, some: Float) -> Array<String, Float>
}
"""

let overloadMock4 =
"""


class FooMock: Foo {
    init() { }


    private(set) var updateCallCount = 0
    var updateHandler: ((Int, Float) -> ())?
    func update(arg: Int, some: Float)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler(arg, some)
        }
        
    }

    private(set) var updateArgCallCount = 0
    var updateArgHandler: ((Int, Float) -> (Int))?
    func update(arg: Int, some: Float) -> Int {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg, some)
        }
        return 0
    }

    private(set) var updateArgSomeCallCount = 0
    var updateArgSomeHandler: ((Int, Float) -> (Observable<Int>))?
    func update(arg: Int, some: Float) -> Observable<Int> {
        updateArgSomeCallCount += 1
        if let updateArgSomeHandler = updateArgSomeHandler {
            return updateArgSomeHandler(arg, some)
        }
        return Observable<Int>.empty()
    }

    private(set) var updateArgSomeIntCallCount = 0
    var updateArgSomeIntHandler: ((Int, Float) -> ((String) -> Observable<Double>))?
    func update(arg: Int, some: Float) -> (String) -> Observable<Double> {
        updateArgSomeIntCallCount += 1
        if let updateArgSomeIntHandler = updateArgSomeIntHandler {
            return updateArgSomeIntHandler(arg, some)
        }
        fatalError("updateArgSomeIntHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var updateArgSomeIntFloatCallCount = 0
    var updateArgSomeIntFloatHandler: ((Int, Float) -> (Array<String, Float>))?
    func update(arg: Int, some: Float) -> Array<String, Float> {
        updateArgSomeIntFloatCallCount += 1
        if let updateArgSomeIntFloatHandler = updateArgSomeIntFloatHandler {
            return updateArgSomeIntFloatHandler(arg, some)
        }
        return Array<String, Float>()
    }
}

"""
