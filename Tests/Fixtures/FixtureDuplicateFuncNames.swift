import SwiftMockGenCore


let simpleDuplicates = """
/// \(String.mockAnnotation)
public protocol SimpleDuplicate {
func push(state: Double,
attachTransition: Int,
detachTransition: Float?)

func push(state: Double,
flag: Float,
attachTransition: Int,
detachTransition: Float?)
}
"""

let simpleDuplicatesMock = """
public class SimpleDuplicateMock: SimpleDuplicate {
    public init() {
        
    }
    
    var pushCallCount = 0
    var pushHandler: ((Double, Int, Float?) -> ())?
    public func push(state: Double, attachTransition: Int, detachTransition: Float?)  {
        pushCallCount += 1
        if let pushHandler = pushHandler {
            return pushHandler(state, attachTransition, detachTransition)
        }
        
    }
    var pushStateFlagCallCount = 0
    var pushStateFlagHandler: ((Double, Float, Int, Float?) -> ())?
    public func push(state: Double, flag: Float, attachTransition: Int, detachTransition: Float?)  {
        pushStateFlagCallCount += 1
        if let pushStateFlagHandler = pushStateFlagHandler {
            return pushStateFlagHandler(state, flag, attachTransition, detachTransition)
        }
        
    }
}
"""


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
    var updateInt3CallCount = 0
    var updateInt3Handler: (() -> (Int))?
    func update() -> Int {
        updateInt3CallCount += 1
        if let updateInt3Handler = updateInt3Handler {
            return updateInt3Handler()
        }
        return 0
    }
    var updateArgCallCount = 0
    var updateArgHandler: ((Int) -> ())?
    func update(arg: Int)  {
        updateArgCallCount += 1
        if let updateArgHandler = updateArgHandler {
            return updateArgHandler(arg)
        }
        
    }
    var updateArg4CallCount = 0
    var updateArg4Handler: ((Float) -> ())?
    func update(arg: Float)  {
        updateArg4CallCount += 1
        if let updateArg4Handler = updateArg4Handler {
            return updateArg4Handler(arg)
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
    var updateArgSomeInt5CallCount = 0
    var updateArgSomeInt5Handler: ((Int, Float) -> (Int))?
    func update(arg: Int, some: Float) -> Int {
        updateArgSomeInt5CallCount += 1
        if let updateArgSomeInt5Handler = updateArgSomeInt5Handler {
            return updateArgSomeInt5Handler(arg, some)
        }
        return 0
    }
    var updateArgSomeObservableInt5CallCount = 0
    var updateArgSomeObservableInt5Handler: ((Int, Float) -> (Observable<Int>))?
    func update(arg: Int, some: Float) -> Observable<Int> {
        updateArgSomeObservableInt5CallCount += 1
        if let updateArgSomeObservableInt5Handler = updateArgSomeObservableInt5Handler {
            return updateArgSomeObservableInt5Handler(arg, some)
        }
        return Observable.empty()
    }
    var updateArgSomeStringObservableDouble5CallCount = 0
    var updateArgSomeStringObservableDouble5Handler: ((Int, Float) -> ((String) -> Observable<Double>))?
    func update(arg: Int, some: Float) -> (String) -> Observable<Double> {
        updateArgSomeStringObservableDouble5CallCount += 1
        if let updateArgSomeStringObservableDouble5Handler = updateArgSomeStringObservableDouble5Handler {
            return updateArgSomeStringObservableDouble5Handler(arg, some)
        }
        fatalError("updateArgSomeStringObservableDouble5Handler returns can't have a default value thus its handler must be set")
    }
    var updateArgSomeArrayStringFloat5CallCount = 0
    var updateArgSomeArrayStringFloat5Handler: ((Int, Float) -> (Array<String, Float>))?
    func update(arg: Int, some: Float) -> Array<String, Float> {
        updateArgSomeArrayStringFloat5CallCount += 1
        if let updateArgSomeArrayStringFloat5Handler = updateArgSomeArrayStringFloat5Handler {
            return updateArgSomeArrayStringFloat5Handler(arg, some)
        }
        fatalError("updateArgSomeArrayStringFloat5Handler returns can't have a default value thus its handler must be set")
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
        fatalError("collectionViewSizeForItemAtHandler returns can't have a default value thus its handler must be set")
    }
    var collectionViewDidEndDisplayingForItemAtCallCount = 0
    var collectionViewDidEndDisplayingForItemAtHandler: ((UICollectionView, UICollectionViewCell, Int) -> ())?
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt index: Int)  {
        collectionViewDidEndDisplayingForItemAtCallCount += 1
        if let collectionViewDidEndDisplayingForItemAtHandler = collectionViewDidEndDisplayingForItemAtHandler {
            return collectionViewDidEndDisplayingForItemAtHandler(collectionView, cell, index)
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
    var loadImageAtURLInitialRetryDelayMaxAttemptsCallCount = 0
    var loadImageAtURLInitialRetryDelayMaxAttemptsHandler: ((URL, RxTimeInterval, Int) -> (Observable<UIImage>))?
    func loadImage(atURL url: URL, initialRetryDelay: RxTimeInterval, maxAttempts: Int) -> Observable<UIImage> {
        loadImageAtURLInitialRetryDelayMaxAttemptsCallCount += 1
        if let loadImageAtURLInitialRetryDelayMaxAttemptsHandler = loadImageAtURLInitialRetryDelayMaxAttemptsHandler {
            return loadImageAtURLInitialRetryDelayMaxAttemptsHandler(url, initialRetryDelay, maxAttempts)
        }
        return Observable.empty()
    }
}
"""
