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

func main() {
    var args = CommandLine.arguments
    let execName = args.removeFirst()
    print("Start of", execName)

    if args.count > 2 {
        let srcDir = args.removeFirst()
        let destDir = args.removeFirst()
        print("Running MockGen on", srcDir, "output: ", destDir)
        generateMocks(srcDir, inputMockPaths: args, destinationDir: destDir)
    }
    
    print("End of", execName)
}

main()
