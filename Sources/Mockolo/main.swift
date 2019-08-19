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
import Utility
import Basic

func main() {
    
    let parser = ArgumentParser(usage: "<options>", overview: "Mockolo: Swift mock generator.")
    let command = Executor(parser: parser)
    let inputs = Array(CommandLine.arguments.dropFirst())

    print("Start...")
    do {
        /* Example:
         .build/release/mockolo -srcs File1.swift File2.swift -out result/Mocks.swift -mocks FooMocks.swift -exclude "Mocks" "Tests"
         */
        let args = try parser.parse(inputs)
        command.mexecute(with: args)
    } catch {
        fatalError("Command-line pasing error (use --help for help): \(error)")
    }
    
    print("Done.")
}


main()
