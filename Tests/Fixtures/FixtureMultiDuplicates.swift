import SwiftMockGenCore

let duplicateFuncNames = """
import UIKit

/// \(String.mockAnnotation)
protocol DuplicateFuncNames {
func display()
func display(x: Int)
func display(y: Int)
func update()
func update() -> Int
func update(arg: Int)
func update(arg: Float)
func update(arg: Int, some: Float)
func update(arg: Int, some: Float) -> Int
func update(arg: Int, some: Float) -> Observable<Int>
func update(arg: Int, some: Float) -> (String) -> Observable<Double>
func update(arg: Int, some: Float) -> Array<String, Float>

func collectionView(_ collectionView: UICollectionView, reuseIdentifierForItemAt index: Int) -> String?
func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt index: Int)
func collectionView(_ collectionView: UICollectionView, sizeForItemAt index: Int) -> CGSize
func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)
func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt index: Int)
func loadImage(atURL url: URL) -> Observable<UIImage>
func loadImage(atURL url: URL, placeholder: UIImage) -> Observable<UIImage>
func loadImage(atURL url: URL, initialRetryDelay: RxTimeInterval, maxAttempts: Int) -> Observable<UIImage>

}
"""

let duplicateFuncNamesMock = """
import UIKit

class DuplicateFuncNamesMock: DuplicateFuncNames {

init() {

}

var displayCallCount = 0
var displayHandler: (() -> ())?
func display()  {
displayCallCount += 1
if let displayHandler = displayHandler {
return displayHandler()
}

}
var displayXCallCount = 0
var displayXHandler: ((Int) -> ())?
func display(x: Int)  {
displayXCallCount += 1
if let displayXHandler = displayXHandler {
return displayXHandler(x)
}

}
var displayYCallCount = 0
var displayYHandler: ((Int) -> ())?
func display(y: Int)  {
displayYCallCount += 1
if let displayYHandler = displayYHandler {
return displayYHandler(y)
}

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
var updateArgCallCount = 0
var updateArgHandler: ((Float) -> ())?
func update(arg: Float)  {
updateArgCallCount += 1
if let updateArgHandler = updateArgHandler {
return updateArgHandler(arg)
}

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
var collectionViewCallCount = 0
var collectionViewHandler: ((UICollectionView, Int) -> (String?))?
func collectionView(_ collectionView: UICollectionView, reuseIdentifierForItemAt index: Int) -> String? {
collectionViewCallCount += 1
if let collectionViewHandler = collectionViewHandler {
return collectionViewHandler(collectionView, index)
}
return nil
}
var collectionViewConfigureCellCallCount = 0
var collectionViewConfigureCellHandler: ((UICollectionView, UICollectionViewCell, Int) -> ())?
func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt index: Int)  {
collectionViewConfigureCellCallCount += 1
if let collectionViewConfigureCellHandler = collectionViewConfigureCellHandler {
return collectionViewConfigureCellHandler(collectionView, cell, index)
}

}
var collectionViewSizeForItemAtCallCount = 0
var collectionViewSizeForItemAtHandler: ((UICollectionView, Int) -> (CGSize))?
func collectionView(_ collectionView: UICollectionView, sizeForItemAt index: Int) -> CGSize {
collectionViewSizeForItemAtCallCount += 1
if let collectionViewSizeForItemAtHandler = collectionViewSizeForItemAtHandler {
return collectionViewSizeForItemAtHandler(collectionView, index)
}
return .zero
}
var collectionViewDidEndDisplayingCallCount = 0
var collectionViewDidEndDisplayingHandler: ((UICollectionView, UICollectionViewCell, Int) -> ())?
func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)  {
collectionViewDidEndDisplayingCallCount += 1
if let collectionViewDidEndDisplayingHandler = collectionViewDidEndDisplayingHandler {
return collectionViewDidEndDisplayingHandler(collectionView, cell, index)
}

}
var collectionViewConfigureCellForItemAtCallCount = 0
var collectionViewConfigureCellForItemAtHandler: ((UICollectionView, UICollectionViewCell, Int) -> ())?
func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt index: Int)  {
collectionViewConfigureCellForItemAtCallCount += 1
if let collectionViewConfigureCellForItemAtHandler = collectionViewConfigureCellForItemAtHandler {
return collectionViewConfigureCellForItemAtHandler(collectionView, cell, index)
}

}
var loadImageCallCount = 0
var loadImageHandler: ((URL) -> (Observable<UIImage>))?
func loadImage(atURL url: URL) -> Observable<UIImage> {
loadImageCallCount += 1
if let loadImageHandler = loadImageHandler {
return loadImageHandler(url)
}
return Observable.empty()
}
var loadImageAtURLCallCount = 0
var loadImageAtURLHandler: ((URL, UIImage) -> (Observable<UIImage>))?
func loadImage(atURL url: URL, placeholder: UIImage) -> Observable<UIImage> {
loadImageAtURLCallCount += 1
if let loadImageAtURLHandler = loadImageAtURLHandler {
return loadImageAtURLHandler(url, placeholder)
}
return Observable.empty()
}
var loadImageAtURLInitialRetryDelayCallCount = 0
var loadImageAtURLInitialRetryDelayHandler: ((URL, RxTimeInterval, Int) -> (Observable<UIImage>))?
func loadImage(atURL url: URL, initialRetryDelay: RxTimeInterval, maxAttempts: Int) -> Observable<UIImage> {
loadImageAtURLInitialRetryDelayCallCount += 1
if let loadImageAtURLInitialRetryDelayHandler = loadImageAtURLInitialRetryDelayHandler {
return loadImageAtURLInitialRetryDelayHandler(url, initialRetryDelay, maxAttempts)
}
return Observable.empty()
}
}
"""
