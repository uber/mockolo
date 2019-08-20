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
import SourceKittenFramework

func scanDirectory(_ path: String, with callBack: (String) -> Void) {
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

func scanPaths(_ paths: [String], with callBack: (String) -> Void) {
    for path in paths {
        scanDirectory(path, with: callBack)
    }
}
