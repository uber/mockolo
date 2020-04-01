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
 * The following can be called by functions of mocked protocols or classes, with
 * a commandline input option, --use-template-func. See MockFuncTests for more examples.
 *
 *  E.g.
 *
 *  class BarMock: Bar {
 *      func foo(arg: Int) -> Int {
 *          mockFunc(&fooCallCount)("foo", fooHandler?(arg), MockReturn.val(0))
 *      }
 *  }
 *
 * mockFunc first increments the call count of the function foo (fooCallCount += 1), and
 * then calls the handler (fooHandler) if non-nil with arguments passed into the function.
 * If the handler is nil, it provides a default value (MockReturn.val) for the return type
 * if applicable.
 */


///
/// Utility mock function called by a function being mocked.
/// It first increments the function call count, then performs its handler call if non-nil,
/// else return a default value if applicable.
///
/// The function being mocked that calls this will look like this:
///     func foo(arg: Int) -> Int {
///       mockFunc(&fooCallCount)("foo", fooHandler?(arg), MockReturn.val(0))
///     }
///
public func mockFunc<T>(_ count: inout Int) -> (String, T?, MockReturn<T>) -> (T) {
    count += 1
    return { name, handlerResult, elseReturn in
        if let result = handlerResult {
            return result
        }
        return mockReturnStmt(elseReturn, for: name)
    }
}


/// The following is called for an optional return type
public func mockFunc<T: ExpressibleByNilLiteral>(_ count: inout Int) -> (String, T, MockReturn<T>) -> (T) {
    count += 1
    return { name, handlerResult, elseReturn in
        return handlerResult
    }
}

/// Used to mock a default return value if applicable or fatalError
public enum MockReturn<T> {
    case void
    case val(_: T)
    case error
}

private func mockReturnStmt<T>(_ mockReturn: MockReturn<T>,
                              for name: String) -> T {

    switch mockReturn {
    case .void:
        if let v = Void() as? T {
            return v
        }
    case .val(let value):
        return value
    default:
        break
    }

    fatalError("\(name) handler must be set as there's no default value to return")
}

