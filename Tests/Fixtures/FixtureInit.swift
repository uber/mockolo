import SwiftMockGenCore

let simpleInit = """
import Foundation

/// \(MockAnnotation)
protocol Current: Parent {
var title: String { get set }
}

"""

let simpleInitParentMock = """
public class ParentMock: Parent {
let num: Int
public init(arg: Int) {
self.num = arg
}
}
"""

let simpleInitResultMock = """
\(HeaderDoc)
\(PoundIfMock)
import Foundation


class CurrentMock: Current {
init(num: Int = 0, title: String = "") {
self.num = num
self.title = title
}

let num: Int

var titleSetCallCount = 0
var underlyingTitle: String = ""
var title: String {
get {
return underlyingTitle
}
set {
underlyingTitle = newValue
titleSetCallCount += 1
}
}
}
\(PoundEndIf)
"""
