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
import os.signpost

fileprivate let perfLog = OSLog(subsystem: "mockolo", category: "PointsOfInterest")

public var minLogLevel = 0

/// Logs status and other messages depending on the level provided
public enum LogLevel: Int {
    case verbose
    case info
    case warning
    case error
}

public func log(_ arg: Any..., level: LogLevel = .info) {
    guard level.rawValue >= minLogLevel else { return }
    switch level {
    case .info, .verbose:
        print(arg)
    case .warning:
        print("WARNING: \(arg)")
    case .error:
        print("ERROR: \(arg)")
    }
}

public func signpost_begin(name: StaticString) {
    if minLogLevel == LogLevel.verbose.rawValue {
        os_signpost(.begin, log: perfLog, name: name)
    }
}

public func signpost_end(name: StaticString) {
    if minLogLevel == LogLevel.verbose.rawValue {
        os_signpost(.end, log: perfLog, name: name)
    }
}
