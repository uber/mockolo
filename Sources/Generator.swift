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

func generateMocks(_ srcDir: String, inputMockPaths: [String], destinationDir: String) {

    var candidates = [String: String]()
    var parentMocks = [String: (String, Structure)]()
    
    let outputPath = "Mocks.swift"
    let mockgenQueue = DispatchQueue(label: "mockgen-q", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent)
    let q2 = DispatchQueue(label: "mockgen-q", qos: DispatchQoS.userInteractive, attributes: DispatchQueue.Attributes.concurrent)

    let t0 = CFAbsoluteTimeGetCurrent()
    print("Build a map of input mocks to be inherited...")
    _ = processFiles(inputMockPaths, queue: mockgenQueue) { (s: Structure, file: File) in
        if s.isClass, s.name.hasSuffix("Mock") {
            parentMocks[s.name] = (file.contents, s)
        }
    }
    
    let t1 = CFAbsoluteTimeGetCurrent()
    print("Took", t1-t0)

    print("Render a mock output for annotated protocols...")
    _ = processRendering([srcDir], inputMocks: parentMocks, queue: q2) { (s: Structure, file: File, mockString: String) in
            if !mockString.isEmpty {
                candidates[s.name] = mockString
            }
    }
    
    let t2 = CFAbsoluteTimeGetCurrent()
    print("Took", t2-t1)
    
    print("Combine all of mock output into one...")
    let entities = candidates.map{$0.1}
    let ret = entities.joined()
    
    let t3 = CFAbsoluteTimeGetCurrent()
    print("Took", t3-t2)
    
    print("Write the output to a file...")
    let outputFile = destinationDir + "/" + outputPath
    _ = try? ret.write(toFile: outputFile, atomically: true, encoding: String.Encoding.utf8)

    let t4 = CFAbsoluteTimeGetCurrent()
    print("Took", t4-t3)
}
