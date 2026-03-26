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

@propertyWrapper
indirect enum CoW<Value> {
    case storage(Value)

    init(_ value: Value) {
        self = .storage(value)
    }

    init(wrappedValue: Value) {
        self = .storage(wrappedValue)
    }

    var wrappedValue: Value {
        get {
            switch self {
            case .storage(let v): return v
            }
        }
        set {
            self = .storage(newValue)
        }
    }
}

extension CoW: Equatable where Value: Equatable {
    static func == (lhs: CoW<Value>, rhs: CoW<Value>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}
