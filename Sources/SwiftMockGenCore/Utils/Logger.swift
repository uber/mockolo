//
//  Logswift.swift
//  SwiftMockGenCore
//
//  Created by ellie on 4/29/19.
//

import Foundation

/// Logs status and other messages depending on the level provided
public struct Logger {
    
    public enum Level: Int {
        case message
        case verbose
        case error
    }
    
    public static var level: Level = .message

    public static func log(_ arg: Any...) {
        switch level {
        case .verbose:
            print(arg)
        case .error:
            print("ERROR: \(arg)")
        default:
            break
        }
    }
}
