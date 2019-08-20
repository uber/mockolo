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
    
    private var _doneInit = false
    private var arg: String!
    public init() { _doneInit = true }
    required public init(arg: String) {
        self.arg = arg
        _doneInit = true
    }
    public var numSetCallCount = 0
    var underlyingNum: Int = 0
    public var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            if _doneInit { numSetCallCount += 1 }
        }
    }
    public var rateSetCallCount = 0
    var underlyingRate: Double = 0.0
    public var rate: Double {
        get {
            return underlyingRate
        }
        set {
            underlyingRate = newValue
            if _doneInit { rateSetCallCount += 1 }
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
    private var _doneInit = false
    public init() {_doneInit = true}
    public init(num: Int, rate: Double) {
        self.num = arg
        self.rate = rate
        _doneInit = true
    }
    
    public var numSetCallCount = 0
    var underlyingNum: Int = 0
    public var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            if _doneInit { numSetCallCount += 1 }
        }
    }
    
    public var rateSetCallCount = 0
    var underlyingRate: Double = 0.0
    public var rate: Double {
        get {
            return underlyingRate
        }
        set {
            underlyingRate = newValue
            if _doneInit { rateSetCallCount += 1 }
        }
    }
}

"""

let simpleInitResultMock =
"""

import Foundation


public class CurrentMock: Current {
    
    private var _doneInit = false
    public init() { _doneInit = true }
    public init(title: String = "", num: Int = 0, rate: Double = 0.0) {
        self.title = title
        self.num = num
        self.rate = rate
        _doneInit = true
    }
    public var titleSetCallCount = 0
    var underlyingTitle: String = ""
    public var title: String {
        get { return underlyingTitle }
        set {
            underlyingTitle = newValue
            if _doneInit { titleSetCallCount += 1 }
        }
    }
    public var numSetCallCount = 0
    var underlyingNum: Int = 0
    public var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            if _doneInit { numSetCallCount += 1 }
        }
    }
    public var rateSetCallCount = 0
    var underlyingRate: Double = 0.0
    public var rate: Double {
        get {
            return underlyingRate
        }
        set {
            underlyingRate = newValue
            if _doneInit { rateSetCallCount += 1 }
        }
    }
}

"""
