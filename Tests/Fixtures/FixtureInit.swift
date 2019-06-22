import MockoloFramework

//  MARK - protocol containing init

let protocolWithInit = """
/// \(String.mockAnnotation)
public protocol HasInit: Parent {
    init(arg: String)
}
"""

let protocolWithInitResultMock =
"""
public class HasInitMock: HasInit {
    
    private var arg: String!
    public init(arg: String) {
        self.arg = arg
    }
    var numSetCallCount = 0
    var underlyingNum: Int = 0
    public var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            numSetCallCount += 1
        }
    }
    var rateSetCallCount = 0
    var underlyingRate: Double = 0.0
    public var rate: Double {
        get {
            return underlyingRate
        }
        set {
            underlyingRate = newValue
            rateSetCallCount += 1
        }
    }
}

"""

//  MARK - simple init

let simpleInit = """
import Foundation

/// \(String.mockAnnotation)
public protocol Current: Parent {
    var title: String { get set }
}

"""

let simpleInitParentMock = """
public class ParentMock: Parent {
    public init() {}
    public init(num: Int, rate: Double) {
        self.num = arg
        self.rate = rate
    }
    
    var numSetCallCount = 0
    var underlyingNum: Int = 0
    public var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            numSetCallCount += 1
        }
    }
    
    var rateSetCallCount = 0
    var underlyingRate: Double = 0.0
    public var rate: Double {
        get {
            return underlyingRate
        }
        set {
            underlyingRate = newValue
            rateSetCallCount += 1
        }
    }
}

"""

let simpleInitResultMock = """
import Foundation

public class CurrentMock: Current {
    public init() {}
    public init(title: String = "", num: Int = 0, rate: Double = 0.0) {
        self.title = title
        self.num = num
        self.rate = rate
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
    var numSetCallCount = 0
    var underlyingNum: Int = 0
    public var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            numSetCallCount += 1
        }
    }
    var rateSetCallCount = 0
    var underlyingRate: Double = 0.0
    public var rate: Double {
        get {
            return underlyingRate
        }
        set {
            underlyingRate = newValue
            rateSetCallCount += 1
        }
    }
}
"""
