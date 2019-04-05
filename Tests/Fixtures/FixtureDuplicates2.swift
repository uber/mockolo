import SwiftMockGenCore

let duplicates2 = """
/// \(String.mockAnnotation)
protocol DuplicateFuncNames {
func update(arg: Int, some: Float)
func update(arg: Int, some: Float) -> Int
func update(arg: Int, some: Float) -> Observable<Int>
func update(arg: Int, some: Float) -> (String) -> Observable<Double>
func update(arg: Int, some: Float) -> Array<String, Float>
}
"""

let duplicatesMock2 =
"""
class DuplicateFuncNamesMock: DuplicateFuncNames {
    
    init() {
        
    }
    
    var updateCallCount = 0
    var updateHandler: ((Int, Float) -> ())?
    func update(arg: Int, some: Float)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            return updateHandler(arg, some)
        }
        
    }
    var updateArgCallCount = 0
    var updateArgHandler: ((Int, Float) -> (Int))?
    func update(arg: Int, some: Float) -> Int {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg, some)
        }
        return 0
    }
    var updateArgSomeCallCount = 0
    var updateArgSomeHandler: ((Int, Float) -> (Observable<Int>))?
    func update(arg: Int, some: Float) -> Observable<Int> {
        updateArgSomeCallCount += 1
        if let updateArgSomeHandler = updateArgSomeHandler {
            return updateArgSomeHandler(arg, some)
        }
        return Observable.empty()
    }
    var updateArgSomeIntCallCount = 0
    var updateArgSomeIntHandler: ((Int, Float) -> ((String) -> Observable<Double>))?
    func update(arg: Int, some: Float) -> (String) -> Observable<Double> {
        updateArgSomeIntCallCount += 1
        if let updateArgSomeIntHandler = updateArgSomeIntHandler {
            return updateArgSomeIntHandler(arg, some)
        }
        fatalError("updateArgSomeIntHandler returns can't have a default value thus its handler must be set")
    }
    var updateArgSomeIntFloatCallCount = 0
    var updateArgSomeIntFloatHandler: ((Int, Float) -> (Array<String, Float>))?
    func update(arg: Int, some: Float) -> Array<String, Float> {
        updateArgSomeIntFloatCallCount += 1
        if let updateArgSomeIntFloatHandler = updateArgSomeIntFloatHandler {
            return updateArgSomeIntFloatHandler(arg, some)
        }
        fatalError("updateArgSomeIntFloatHandler returns can't have a default value thus its handler must be set")
    }
}
"""
