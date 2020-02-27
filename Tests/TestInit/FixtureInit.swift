import MockoloFramework


let keywordParams = """
/// \(String.mockAnnotation)
protocol KeywordProtocol {
    init(in: Int)
}

class KClass {
    var k: Int = 0
    init(in: Int) {
        self.k = `in`
    }
}

/// \(String.mockAnnotation)
class KeywordClass: KClass {
    override init(in: Int) {
        super.init(in: `in`)
    }
}
"""

let keywordParamsMock = """

class KeywordProtocolMock: KeywordProtocol {
    private var _doneInit = false
    private var `in`: Int!
    init() { _doneInit = true }
    required init(in: Int = 0) {
        self.in = `in`
        _doneInit = true
    }
}

class KeywordClassMock: KeywordClass {
    private var _doneInit = false
    override init(in: Int = 0) {
        super.init(in: `in`)
        _doneInit = true
    }
}

"""


//  MARK - protocol containing init

let protocolWithInit = """
/// \(String.mockAnnotation)
public protocol HasInit: HasInitParent {
    init(arg: String)
}
"""



let protocolWithInitParentMock = """
public protocol HasInitParent {
}
public class HasInitParentMock: HasInitParent {
    private var _doneInit = false
    public init() {_doneInit = true}
    required public init(order: Int) {
        self.order = order
        _doneInit = true
    }
    public init(num: Int, rate: Double) {
        self.rate = rate
        _doneInit = true
    }
    public var orderSetCallCount = 0
    var underlyingOrder: Int = 0
    public var order: Int {
        get {
            return underlyingOrder
        }
        set {
            underlyingOrder = newValue
            if _doneInit { orderSetCallCount += 1 }
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

let protocolWithInitResultMock = """

public class HasInitMock: HasInit {
    
    private var _doneInit = false
    private var arg: String!
    public init() { _doneInit = true }
    public init(order: Int = 0, num: Int = 0, rate: Double = 0.0) {
        self.order = order
        self.num = num
        self.rate = rate
        _doneInit = true
    }
    required public init(arg: String = "") {
        self.arg = arg
        _doneInit = true
    }

    required public init(order: Int) {
        self.order = order
        _doneInit = true
    }

    public var orderSetCallCount = 0

    var underlyingOrder: Int = 0

    public var order: Int {
        get {
            return underlyingOrder
        }
        set {
            underlyingOrder = newValue
            if _doneInit { orderSetCallCount += 1 }
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

let simpleInitResultMock = """
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
        public var title: String = "" { didSet { titleSetCallCount += 1 } }

        
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


let nonSimpleInitVars = """

public typealias ForcastCheckBlock = () -> ForcastUpdateConfig?

/// \(String.mockAnnotation)
@objc public protocol ForcastUpdating {
    @objc init(checkBlock: @escaping ForcastCheckBlock, dataStream: DataStream)
    @objc func enabled() -> Bool
    @objc func forcastLoader() -> ForcastLoading?
    @objc func fetchInfo(fromItmsURL itmsURL: URL, completionHandler: @escaping (String?, URL?) -> ())
}
"""


let nonSimpleInitVarsMock =
"""
public class ForcastUpdatingMock: ForcastUpdating {

    private var _doneInit = false
    private var checkBlock: ForcastCheckBlock!
    private var dataStream: DataStream!
    public init() { _doneInit = true }
    required public init(checkBlock: @escaping ForcastCheckBlock, dataStream: DataStream) {
        self.checkBlock = checkBlock
        self.dataStream = dataStream
        _doneInit = true
    }

    public var enabledCallCount = 0
    public var enabledHandler: (() -> (Bool))?
    public func enabled() -> Bool {
            enabledCallCount += 1
    
            if let enabledHandler = enabledHandler {
                return enabledHandler()
            }
            return false
    }
    public var forcastLoaderCallCount = 0
    public var forcastLoaderHandler: (() -> (ForcastLoading?))?
    public func forcastLoader() -> ForcastLoading? {
            forcastLoaderCallCount += 1
    
            if let forcastLoaderHandler = forcastLoaderHandler {
                return forcastLoaderHandler()
            }
            return nil
    }
    public var fetchInfoCallCount = 0
    public var fetchInfoHandler: ((URL, @escaping (String?, URL?) -> ()) -> ())?
    public func fetchInfo(fromItmsURL itmsURL: URL, completionHandler: @escaping (String?, URL?) -> ())  {
            fetchInfoCallCount += 1
    
            if let fetchInfoHandler = fetchInfoHandler {
                fetchInfoHandler(itmsURL, completionHandler)
            }
    }
}

"""

