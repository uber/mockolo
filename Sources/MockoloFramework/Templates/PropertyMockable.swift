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


#if RxSwiftImported

/**
 The following property wrappers may be used for RxSwift observable variables to be mocked.
 There are two, public and internal, since the access levels should match the properties declared.

 E.g.
 public class FooMock: Foo {
    @MockObservable  public var bazStream: Observable<Int> { get }
 }

 class BarMock: Bar {
    @MockObservableInternal  var bazStream: Observable<Int> { get }
 }
 */

import RxSwift

@propertyWrapper
public struct MockObservable<Value: ObservableType> {
    var whichKind = 0
    public var callCount = 0
    public var publishSubject: PublishSubject<Value.E> = PublishSubject<Value.E>()
    public var replaySubject: ReplaySubject<Value.E> = ReplaySubject<Value.E>.create(bufferSize: 1)
    public var behaviorSubject: BehaviorSubject<Value.E>!
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
        if let val = newValue as? PublishSubject<Value.E> {
            publishSubject = val
            whichKind = 0
        } else if let val = newValue as? ReplaySubject<Value.E> {
            replaySubject = val
            whichKind = 1
        } else if let val = newValue as? BehaviorSubject<Value.E> {
            behaviorSubject = val
            whichKind = 2
        } else {
            fallback = newValue
            whichKind = 3
        }
    }
}

@propertyWrapper
struct MockObservableInternal<Value: ObservableType> {
    var callCount = 0
    var whichKind = 0
    var publishSubject: PublishSubject<Value.E> = PublishSubject<Value.E>()
    var replaySubject: ReplaySubject<Value.E> = ReplaySubject<Value.E>.create(bufferSize: 1)
    var behaviorSubject: BehaviorSubject<Value.E>!
    var fallback: Value!
    init(wrappedValue: Value) {
        storeVal(wrappedValue)
    }
    
    var wrappedValue: Value {
        get {
            if whichKind == 0 { return publishSubject as! Value  }
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
        if let val = newValue as? PublishSubject<Value.E> {
            publishSubject = val
            whichKind = 0
        } else if let val = newValue as? ReplaySubject<Value.E> {
            replaySubject = val
            whichKind = 1
        } else if let val = newValue as? BehaviorSubject<Value.E> {
            behaviorSubject = val
            whichKind = 2
        } else {
            fallback = newValue
            whichKind = 3
        }
    }
}

#endif

