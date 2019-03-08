import SwiftMockGenCore

let duplicateFuncNames = """

/// \(MockAnnotation)
protocol DuplicateFuncNames {
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
var updateArgIntSomeFloatObservableIntCallCount = 0
var updateArgIntSomeFloatObservableIntHandler: ((Int, Float) -> (Observable<Int>))?
func update(arg: Int, some: Float) -> Observable<Int> {
updateArgIntSomeFloatObservableIntCallCount += 1
if let updateArgIntSomeFloatObservableIntHandler = updateArgIntSomeFloatObservableIntHandler {
return updateArgIntSomeFloatObservableIntHandler(arg, some)
}
return Observable.empty()
}
var updateArgIntSomeFloatStringObservableDoubleCallCount = 0
var updateArgIntSomeFloatStringObservableDoubleHandler: ((Int, Float) -> ((String) -> Observable<Double>))?
func update(arg: Int, some: Float) -> (String) -> Observable<Double> {
updateArgIntSomeFloatStringObservableDoubleCallCount += 1
if let updateArgIntSomeFloatStringObservableDoubleHandler = updateArgIntSomeFloatStringObservableDoubleHandler {
return updateArgIntSomeFloatStringObservableDoubleHandler(arg, some)
}
fatalError("updateArgIntSomeFloatStringObservableDoubleHandler returns can't have a default value thus its handler must be set")
}
var updateArgIntSomeFloatArrayStringFloatCallCount = 0
var updateArgIntSomeFloatArrayStringFloatHandler: ((Int, Float) -> (Array<String, Float>))?
func update(arg: Int, some: Float) -> Array<String, Float> {
updateArgIntSomeFloatArrayStringFloatCallCount += 1
if let updateArgIntSomeFloatArrayStringFloatHandler = updateArgIntSomeFloatArrayStringFloatHandler {
return updateArgIntSomeFloatArrayStringFloatHandler(arg, some)
}
fatalError("updateArgIntSomeFloatArrayStringFloatHandler returns can't have a default value thus its handler must be set")
}
}
\(PoundEndIf)

"""
