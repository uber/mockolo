import MockoloFramework

let simpleVar = """
\(String.headerDoc)
import Foundation

/// \(String.mockAnnotation)
protocol SimpleVar {
    var name: Int { get set }
}
"""

let simpleVarMock = """
import Foundation

class SimpleVarMock: SimpleVar {
    init() {}
    init(name: Int = 0) {
        self.name = name
    }
    
    var nameSetCallCount = 0
    var underlyingName: Int = 0
    var name: Int {
        get {
            return underlyingName
        }
        set {
            underlyingName = newValue
            nameSetCallCount += 1
        }
    }
}
"""



let rxVar =
"""
/// \(String.mockAnnotation)
protocol RxVar {
    var nameStream: Observable<String> { get }
}
"""

let rxVarMock =
"""
class RxVarMock: RxVar {
    
    
    init() {}
    init(nameStream: Observable<String> = PublishSubject()) {
        self.nameStream = nameStream
    }
    
    private var nameStreamSubjectKind = 0
    var nameStreamSubjectSetCallCount = 0
    var nameStreamSubject = PublishSubject<String>() { didSet { nameStreamSubjectSetCallCount += 1 } }
    var nameStreamReplaySubject = ReplaySubject<String>.create(bufferSize: 1) { didSet { nameStreamSubjectSetCallCount += 1 } }
    var nameStreamBehaviorSubject: BehaviorSubject<String>! { didSet { nameStreamSubjectSetCallCount += 1 } }
    var nameStreamRxSubject: Observable<String>! { didSet { nameStreamSubjectSetCallCount += 1 } }
    var nameStream: Observable<String> {
        get {
            if nameStreamSubjectKind == 0 {
                return nameStreamSubject
            } else if nameStreamSubjectKind == 1 {
                return nameStreamBehaviorSubject
            } else if nameStreamSubjectKind == 2 {
                return nameStreamReplaySubject
            } else {
                return nameStreamRxSubject
            }
        }
        set {
            if let val = newValue as? PublishSubject<String> {
                nameStreamSubject = val
                nameStreamSubjectKind = 0
            } else if let val = newValue as? BehaviorSubject<String> {
                nameStreamBehaviorSubject = val
                nameStreamSubjectKind = 1
            } else if let val = newValue as? ReplaySubject<String> {
                nameStreamReplaySubject = val
                nameStreamSubjectKind = 2
            } else {
                nameStreamRxSubject = newValue
                nameStreamSubjectKind = 3
            }
        }
    }
}
"""




let asdf =
"hello"
