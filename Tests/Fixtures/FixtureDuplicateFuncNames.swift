import SwiftMockGenCore

let duplicateFuncNames = """

/// \(MockAnnotation)
protocol DuplicateFuncNames {
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

var updateArgSomeCallCount = 0
var updateArgSomeHandler: ((Int, Float) -> ())?
func update(arg: Int, some: Float)  {
updateArgSomeCallCount += 1
if let updateArgSomeHandler = updateArgSomeHandler {
return updateArgSomeHandler(arg, some)
}

}
var updateArgSomeIntCallCount = 0
var updateArgSomeIntHandler: ((Int, Float) -> (Int))?
func update(arg: Int, some: Float) -> Int {
updateArgSomeIntCallCount += 1
if let updateArgSomeIntHandler = updateArgSomeIntHandler {
return updateArgSomeIntHandler(arg, some)
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
