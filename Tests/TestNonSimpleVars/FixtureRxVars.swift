import MockoloFramework

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

private var _doneInit = false
init() { _doneInit = true }
init(nameStream: Observable<String> = PublishSubject()) {
self.nameStream = nameStream
_doneInit = true
}

private var nameStreamSubjectKind = 0
var nameStreamSubjectSetCallCount = 0
var nameStreamSubject = PublishSubject<String>() { didSet { if _doneInit { nameStreamSubjectSetCallCount += 1 } } }
var nameStreamReplaySubject = ReplaySubject<String>.create(bufferSize: 1) { didSet { if _doneInit { nameStreamSubjectSetCallCount += 1 } } }
var nameStreamBehaviorSubject: BehaviorSubject<String>! { didSet { if _doneInit { nameStreamSubjectSetCallCount += 1 } } }
var nameStreamRxSubject: Observable<String>! { didSet { if _doneInit { nameStreamSubjectSetCallCount += 1 } } }
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

