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
\(String.headerDoc)
\(String.poundIfMock)

public class SimpleDuplicateMock: SimpleDuplicate {
    public init() {
        
    }
    
    var pushStateAttachTransitionDetachTransitionCallCount = 0
    var pushStateAttachTransitionDetachTransitionHandler: ((Double, Int, Float?) -> ())?
    public func push(state: Double, attachTransition: Int, detachTransition: Float?)  {
        pushStateAttachTransitionDetachTransitionCallCount += 1
        if let pushStateAttachTransitionDetachTransitionHandler = pushStateAttachTransitionDetachTransitionHandler {
            return pushStateAttachTransitionDetachTransitionHandler(state, attachTransition, detachTransition)
        }
        
    }
    var pushStateFlagAttachTransitionDetachTransitionCallCount = 0
    var pushStateFlagAttachTransitionDetachTransitionHandler: ((Double, Float, Int, Float?) -> ())?
    public func push(state: Double, flag: Float, attachTransition: Int, detachTransition: Float?)  {
        pushStateFlagAttachTransitionDetachTransitionCallCount += 1
        if let pushStateFlagAttachTransitionDetachTransitionHandler = pushStateFlagAttachTransitionDetachTransitionHandler {
            return pushStateFlagAttachTransitionDetachTransitionHandler(state, flag, attachTransition, detachTransition)
        }
        
    }
}

\(String.poundEndIf)
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
\(String.headerDoc)
\(String.poundIfMock)
import UIKit

class DuplicateFuncNamesMock: DuplicateFuncNames {
    init() {
        
    }
    
    var displayXCallCount = 0
    var displayXHandler: ((Int) -> ())?
    func display(x: Int)  {
        displayXCallCount += 1
        if let displayXHandler = displayXHandler {
            return displayXHandler(x)
        }
        
    }
    var displayCallCount = 0
    var displayHandler: ((Int) -> ())?
    func display(y: Int)  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            return displayHandler(y)
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
    var collectionViewIndexStringCallCount = 0
    var collectionViewIndexStringHandler: ((UICollectionView, Int) -> (String?))?
    func collectionView(_ collectionView: UICollectionView, reuseIdentifierForItemAt index: Int) -> String? {
        collectionViewIndexStringCallCount += 1
        if let collectionViewIndexStringHandler = collectionViewIndexStringHandler {
            return collectionViewIndexStringHandler(collectionView, index)
        }
        return nil
    }
    var collectionViewIndexCGSizeCallCount = 0
    var collectionViewIndexCGSizeHandler: ((UICollectionView, Int) -> (CGSize))?
    func collectionView(_ collectionView: UICollectionView, sizeForItemAt index: Int) -> CGSize {
        collectionViewIndexCGSizeCallCount += 1
        if let collectionViewIndexCGSizeHandler = collectionViewIndexCGSizeHandler {
            return collectionViewIndexCGSizeHandler(collectionView, index)
        }
        fatalError("collectionViewIndexCGSizeHandler returns can't have a default value thus its handler must be set")
    }
    var collectionViewCellUICollectionViewCellIndexIntCallCount = 0
    var collectionViewCellUICollectionViewCellIndexIntHandler: ((UICollectionView, UICollectionViewCell, Int) -> ())?
    func collectionView(_ collectionView: UICollectionView, configureCell cell: UICollectionViewCell, forItemAt index: Int)  {
        collectionViewCellUICollectionViewCellIndexIntCallCount += 1
        if let collectionViewCellUICollectionViewCellIndexIntHandler = collectionViewCellUICollectionViewCellIndexIntHandler {
            return collectionViewCellUICollectionViewCellIndexIntHandler(collectionView, cell, index)
        }
        
    }
    var loadImageUrlCallCount = 0
    var loadImageUrlHandler: ((URL) -> (Observable<UIImage>))?
    func loadImage(atURL url: URL) -> Observable<UIImage> {
        loadImageUrlCallCount += 1
        if let loadImageUrlHandler = loadImageUrlHandler {
            return loadImageUrlHandler(url)
        }
        return Observable.empty()
    }
    var loadImageUrlPlaceholderCallCount = 0
    var loadImageUrlPlaceholderHandler: ((URL, UIImage) -> (Observable<UIImage>))?
    func loadImage(atURL url: URL, placeholder: UIImage) -> Observable<UIImage> {
        loadImageUrlPlaceholderCallCount += 1
        if let loadImageUrlPlaceholderHandler = loadImageUrlPlaceholderHandler {
            return loadImageUrlPlaceholderHandler(url, placeholder)
        }
        return Observable.empty()
    }
    var loadImageUrlInitialRetryDelayMaxAttemptsCallCount = 0
    var loadImageUrlInitialRetryDelayMaxAttemptsHandler: ((URL, RxTimeInterval, Int) -> (Observable<UIImage>))?
    func loadImage(atURL url: URL, initialRetryDelay: RxTimeInterval, maxAttempts: Int) -> Observable<UIImage> {
        loadImageUrlInitialRetryDelayMaxAttemptsCallCount += 1
        if let loadImageUrlInitialRetryDelayMaxAttemptsHandler = loadImageUrlInitialRetryDelayMaxAttemptsHandler {
            return loadImageUrlInitialRetryDelayMaxAttemptsHandler(url, initialRetryDelay, maxAttempts)
        }
        return Observable.empty()
    }
}

\(String.poundEndIf)
"""
