import SwiftMockGenCore

let simpleInit = """
import Foundation

/// \(String.mockAnnotation)
public protocol Current: Parent {
var title: String { get set }
}

"""

let simpleInitParentMock = """
\(String.headerDoc)
\(String.poundIfMock)
public class ParentMock: Parent {
let num: Int
public init(arg: Int) {
self.num = arg
}
}
\(String.poundEndIf)
"""

let simpleInitResultMock = """
\(String.headerDoc)
\(String.poundIfMock)

import Foundation

public class CurrentMock: Current {
    public init(num: Int = 0, title: String = "") {
        self.num = num
        self.title = title
    }
    
    let num: Int
    var titleSetCallCount = 0
    var underlyingTitle: String = ""
    public var title: String {
        get {
            return underlyingTitle
        }
        set {
            underlyingTitle = newValue
            titleSetCallCount += 1
        }
    }
}
\(String.poundEndIf)
"""
