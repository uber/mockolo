
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

import Foundation

public extension Sequence {
    
    func compactMap<T>(path: KeyPath<Element, T?>) -> [T] {
        return compactMap { (element) -> T? in
            element[keyPath: path]
        }
    }
    func map<T>(path: KeyPath<Element, T>) -> [T] {
        return map { (element) -> T in
            element[keyPath: path]
        }
    }
    
    func filter(path: KeyPath<Element, Bool>) -> [Element] {
        return filter { (element) -> Bool in
            element[keyPath: path]
        }
    }
    
    func sorted<T>(path: KeyPath<Element, T>) -> [Element] where T: Comparable {
        return sorted { (lhs, rhs) -> Bool in
            lhs[keyPath: path] < rhs[keyPath: path]
        }
    }

    func sorted<T, U>(path: KeyPath<Element, T>, fallback: KeyPath<Element, U>) -> [Element] where T: Comparable, U: Comparable {
        return sorted { (lhs, rhs) -> Bool in
            if lhs[keyPath: path] == rhs[keyPath: path] {
                return lhs[keyPath: fallback] < rhs[keyPath: fallback]
            }

            return lhs[keyPath: path] < rhs[keyPath: path]
        }
    }
}


