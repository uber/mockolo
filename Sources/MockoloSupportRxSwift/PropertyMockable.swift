//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/**
 The following property wrappers may be used for RxSwift observable variables to be mocked.

 E.g.
 public class FooMock: Foo {
    @MockObservable  public var bazStream: Observable<Int> { get }
 }
 */

#if canImport(RxSwift)
import RxSwift
#else
// ---- Mimic of RxSwift types -----
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
#endif

@propertyWrapper
public struct MockObservable<Value: ObservableType> {
    var whichKind = 0
    public var callCount = 0
    public var publishSubject: PublishSubject<Value.Element> = PublishSubject<Value.Element>()
    public var replaySubject: ReplaySubject<Value.Element> = ReplaySubject<Value.Element>.create(bufferSize: 1)
    public var behaviorSubject: BehaviorSubject<Value.Element>!
    var fallback: Value!
    public init(wrappedValue: Value) {
        storeVal(wrappedValue)
    }
    
    public var wrappedValue: Value {
        get {
            if whichKind == 0 { return publishSubject as! Value }
            else if whichKind == 1 { return replaySubject as! Value  }
            else if whichKind == 2 { return behaviorSubject as! Value  }
            else { return fallback }
        }
        set {
            storeVal(newValue)
            callCount += 1
        }
    }
    
    private mutating func storeVal(_ newValue: Value) {
        if let val = newValue as? PublishSubject<Value.Element> {
            publishSubject = val
            whichKind = 0
        } else if let val = newValue as? ReplaySubject<Value.Element> {
            replaySubject = val
            whichKind = 1
        } else if let val = newValue as? BehaviorSubject<Value.Element> {
            behaviorSubject = val
            whichKind = 2
        } else {
            fallback = newValue
            whichKind = 3
        }
    }
}
