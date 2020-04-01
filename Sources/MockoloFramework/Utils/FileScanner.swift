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

public var scanConcurrencyLimit: Int? = nil

func semaphore(_ numThreads: Int?) -> DispatchSemaphore? {
    let limit = concurrencyLimit(numThreads)
    var sema: DispatchSemaphore?
    if limit > 1 {
        sema = DispatchSemaphore(value: limit)
    }
    return sema
}

func queue(_ numThreads: Int?) -> DispatchQueue? {
    var q: DispatchQueue?
    if concurrencyLimit(numThreads) > 1 {
        q = DispatchQueue(label: "mockolo-queue", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent)
    }
    return q
}

func concurrencyLimit(_ numThreads: Int?) -> Int {
    var limit = 1
    if let n = numThreads {
        limit = n
    } else if let n = scanConcurrencyLimit {
        limit = n
    }
    return limit
}

public func scan(_ paths: [String],
                 isDirectory: Bool,
                 numThreads: Int? = nil,
                 block: @escaping (_ path: String, _ lock: NSLock?) -> ()) {
    if isDirectory {
        scan(dirs: paths, block: block)
    } else {
        scan(paths, block: block)
    }
}

public func scan(dirs: [String],
                 numThreads: Int? = nil,
                 block: @escaping (_ path: String, _ lock: NSLock?) -> ()) {

    if let queue = queue(numThreads) {
        let sema = semaphore(numThreads)
        let lock = NSLock()
        scanDirs(dirs) { filePath in
            _ = sema?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                block(filePath, lock)
                sema?.signal()
            }
        }
        // Wait for queue to drain
        queue.sync(flags: .barrier) {}
    } else {
        scanDirs(dirs) { filePath in
            block(filePath, nil)
        }
    }
}

public func scan<T>(_ elements: [T],
                    numThreads: Int? = nil,
                    block: @escaping (T, NSLock?) -> ()) {

    if let queue = queue(numThreads) {
        let sema = semaphore(numThreads)
        let lock = NSLock()
        for element in elements {
            _ = sema?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                block(element, lock)
                sema?.signal()
            }
        }
        queue.sync(flags: .barrier) { }
    } else {
        for element in elements {
            block(element, nil)
        }
    }
}

public func scan<T, U>(_ elements: [T: U],
                       numThreads: Int? = nil,
                       block: @escaping (T, U, NSLock?) -> ()) {

    if let queue = queue(numThreads) {
        let sema = semaphore(numThreads)
        let lock = NSLock()

        for element in elements {
            _ = sema?.wait(timeout: DispatchTime.distantFuture)
            queue.async {
                block(element.key, element.value, lock)
                sema?.signal()
            }
        }
        queue.sync(flags: .barrier) { }
    } else {
        for element in elements {
            block(element.key, element.value, nil)
        }
    }
}


public func scanDirs(_ paths: [String], with callBack: (String) -> Void) {
    for path in paths {
        scanDir(path, with: callBack)
    }
}

func scanDir(_ path: String, with callBack: (String) -> Void) {
    let errorHandler = { (url: URL, error: Error) -> Bool in
        fatalError("Failed to traverse \(url) with error \(error).")
    }
    if let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: path, isDirectory: true), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: errorHandler) {
        while let nextObjc = enumerator.nextObject() {
            if let fileUrl = nextObjc as? URL {
                callBack(fileUrl.path)
            }
        }
    }
}
