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
    var updateObservableIntCallCount = 0
    var updateObservableIntHandler: ((Int, Float) -> (Observable<Int>))?
    func update(arg: Int, some: Float) -> Observable<Int> {
        updateObservableIntCallCount += 1
        if let updateObservableIntHandler = updateObservableIntHandler {
            return updateObservableIntHandler(arg, some)
        }
        return Observable.empty()
    }
    var updateStringObservableDoubleCallCount = 0
    var updateStringObservableDoubleHandler: ((Int, Float) -> ((String) -> Observable<Double>))?
    func update(arg: Int, some: Float) -> (String) -> Observable<Double> {
        updateStringObservableDoubleCallCount += 1
        if let updateStringObservableDoubleHandler = updateStringObservableDoubleHandler {
            return updateStringObservableDoubleHandler(arg, some)
        }
        fatalError("updateStringObservableDoubleHandler returns can't have a default value thus its handler must be set")
    }
    var updateArrayStringFloatCallCount = 0
    var updateArrayStringFloatHandler: ((Int, Float) -> (Array<String, Float>))?
    func update(arg: Int, some: Float) -> Array<String, Float> {
        updateArrayStringFloatCallCount += 1
        if let updateArrayStringFloatHandler = updateArrayStringFloatHandler {
            return updateArrayStringFloatHandler(arg, some)
        }
        fatalError("updateArrayStringFloatHandler returns can't have a default value thus its handler must be set")
    }
    var collectionViewStringCallCount = 0
    var collectionViewStringHandler: ((UICollectionView, Int) -> (String?))?
    func collectionView(_ collectionView: UICollectionView, reuseIdentifierForItemAt index: Int) -> String? {
        collectionViewStringCallCount += 1
        if let collectionViewStringHandler = collectionViewStringHandler {
            return collectionViewStringHandler(collectionView, index)
        }
        return nil
    }
    var collectionViewCGSizeCallCount = 0
    var collectionViewCGSizeHandler: ((UICollectionView, Int) -> (CGSize))?
    func collectionView(_ collectionView: UICollectionView, sizeForItemAt index: Int) -> CGSize {
        collectionViewCGSizeCallCount += 1
        if let collectionViewCGSizeHandler = collectionViewCGSizeHandler {
            return collectionViewCGSizeHandler(collectionView, index)
        }
        fatalError("collectionViewCGSizeHandler returns can't have a default value thus its handler must be set")
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
