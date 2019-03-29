import SwiftMockGenCore

let simpleInit = """
import Foundation

/// \(String.mockAnnotation)
public protocol Current: Parent {
var title: String { get set }
}

"""

let simpleInitParentMock = """
public class ParentMock: Parent {

var numSetCallCount = 0
var underlyingTitle: String = ""
public var num: Int {
get {
return underlyingNum
}
set {
underlyingNum = newValue
numSetCallCount += 1
}
}

public init() {}
public init(arg: Int) {
self.num = arg
}
}
"""

let simpleInitResultMock = """
import Foundation

public class CurrentMock: Current {
    public init() {}
    public init(num: Int = 0, title: String = "") {
        self.num = num
        self.title = title
    }
    
    var numSetCallCount = 0
    var underlyingTitle: String = ""
    public var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            numSetCallCount += 1
        }
    }
    
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
"""
