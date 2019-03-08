import SwiftMockGenCore

let duplicateFuncNames = """

/// \(MockAnnotation)
protocol DuplicateFuncNames {
func update()
func update() -> Int
func update(arg: Int)
func update(arg: Float)
func update(arg: Int, some: Float)
func update(arg: Int, some: Float) -> Int
func update(arg: Int, some: Float) -> Observable<Int>
func update(arg: Int, some: Float) -> (String) -> Observable<Double>
func update(arg: Int, some: Float) -> Array<String, Float>
}
"""

let duplicateFuncNamesMock = """
\(HeaderDoc)
\(PoundIfMock)

class DuplicateFuncNamesMock: DuplicateFuncNames {
init() {

}

var updateCallCount = 0
var updateHandler: (() -> ())?
func update()  {
updateCallCount += 1
if let updateHandler = updateHandler {
return updateHandler()
}

}
var updateIntCallCount = 0
var updateIntHandler: (() -> (Int))?
func update() -> Int {
updateIntCallCount += 1
if let updateIntHandler = updateIntHandler {
return updateIntHandler()
}
return 0
}
var updateArgIntCallCount = 0
var updateArgIntHandler: ((Int) -> ())?
func update(arg: Int)  {
updateArgIntCallCount += 1
if let updateArgIntHandler = updateArgIntHandler {
return updateArgIntHandler(arg)
}

}
var updateArgFloatCallCount = 0
var updateArgFloatHandler: ((Float) -> ())?
func update(arg: Float)  {
updateArgFloatCallCount += 1
if let updateArgFloatHandler = updateArgFloatHandler {
return updateArgFloatHandler(arg)
}

}
var updateArgIntSomeFloatCallCount = 0
var updateArgIntSomeFloatHandler: ((Int, Float) -> ())?
func update(arg: Int, some: Float)  {
updateArgIntSomeFloatCallCount += 1
if let updateArgIntSomeFloatHandler = updateArgIntSomeFloatHandler {
return updateArgIntSomeFloatHandler(arg, some)
}

}
var updateArgIntSomeFloatIntCallCount = 0
var updateArgIntSomeFloatIntHandler: ((Int, Float) -> (Int))?
func update(arg: Int, some: Float) -> Int {
updateArgIntSomeFloatIntCallCount += 1
if let updateArgIntSomeFloatIntHandler = updateArgIntSomeFloatIntHandler {
return updateArgIntSomeFloatIntHandler(arg, some)
}
return 0
}
var updateArgSomeObservableIntCallCount = 0
var updateArgSomeObservableIntHandler: ((Int, Float) -> (Observable<Int>))?
func update(arg: Int, some: Float) -> Observable<Int> {
updateArgSomeObservableIntCallCount += 1
if let updateArgSomeObservableIntHandler = updateArgSomeObservableIntHandler {
return updateArgSomeObservableIntHandler(arg, some)
}
return Observable.empty()
}
var updateArgSomeStringObservableDoubleCallCount = 0
var updateArgSomeStringObservableDoubleHandler: ((Int, Float) -> ((String) -> Observable<Double>))?
func update(arg: Int, some: Float) -> (String) -> Observable<Double> {
updateArgSomeStringObservableDoubleCallCount += 1
if let updateArgSomeStringObservableDoubleHandler = updateArgSomeStringObservableDoubleHandler {
return updateArgSomeStringObservableDoubleHandler(arg, some)
}
fatalError("updateArgSomeStringObservableDoubleHandler returns can't have a default value thus its handler must be set")
}
var updateArgSomeArrayStringFloatCallCount = 0
var updateArgSomeArrayStringFloatHandler: ((Int, Float) -> (Array<String, Float>))?
func update(arg: Int, some: Float) -> Array<String, Float> {
updateArgSomeArrayStringFloatCallCount += 1
if let updateArgSomeArrayStringFloatHandler = updateArgSomeArrayStringFloatHandler {
return updateArgSomeArrayStringFloatHandler(arg, some)
}
fatalError("updateArgSomeArrayStringFloatHandler returns can't have a default value thus its handler must be set")
}
}
\(PoundEndIf)

"""
