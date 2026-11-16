@MainActor class UIViewController {}
struct CGImage {}
struct CGRect {}

// ---- Dummy RxSwift types -----
protocol ObservableConvertibleType {
    associatedtype Element
    func asObservable() -> any ObservableType
}
protocol ObservableType: ObservableConvertibleType {
}

class Observable<Element>: ObservableType {
    func asObservable() -> any ObservableType {
        fatalError()
    }
    static func empty() -> Observable<Element> {
        fatalError()
    }
}

class BehaviorSubject<Element>: Observable<Element> {
    init(value: Element) {}
}
class PublishSubject<Element>: Observable<Element> {
    override init() {}
}
class ReplaySubject<Element>: Observable<Element> {
    static func create(bufferSize: Int) -> ReplaySubject<Element> {
        fatalError()
    }
}
class BehaviorRelay<Element>: Observable<Element> {}
protocol Disposable {}
// ----
