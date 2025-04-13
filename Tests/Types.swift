@MainActor class UIViewController {}
struct CGImage {}
struct CGRect {}

// ---- Dummy RxSwift types -----
public protocol ObservableConvertibleType {
    associatedtype Element
    func asObservable() -> any ObservableType
}
public protocol ObservableType: ObservableConvertibleType {
}

public class Observable<Element>: ObservableType {
    public func asObservable() -> any ObservableType {
        fatalError()
    }
    public static func empty() -> Observable<Element> {
        fatalError()
    }
}

public class BehaviorSubject<Element>: Observable<Element> {
    public init(value: Element) {}
}
public class PublishSubject<Element>: Observable<Element> {
    public override init() {}
}
public class ReplaySubject<Element>: Observable<Element> {
    public static func create(bufferSize: Int) -> ReplaySubject<Element> {
        fatalError()
    }
}
public class BehaviorRelay<Element>: Observable<Element> {}
// ----
