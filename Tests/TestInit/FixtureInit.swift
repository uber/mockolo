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
    private var _in: Int!
    init() { }

    required init(in: Int = 0) {
        self._in = `in`
    }
}

"""


//  MARK - protocol containing init

let protocolWithBlankInit = """
/// \(String.mockAnnotation)
public protocol BlankInit {
    init()
}
"""

let protocolWithBlankInitMock = """
public class BlankInitMock: BlankInit {
    required public init() {
    }
}
"""

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
    
    public init() {}
    required public init(order: Int) {
        self._order = order
        
    }
    public init(num: Int, rate: Double) {
        self._rate = rate
        
    }
    public var orderSetCallCount = 0
    private var _order: Int = 0 { didSet { orderSetCallCount += 1 } }
    public var order: Int {
        get { return _order }
        set { _order = newValue }
    }

    public var numSetCallCount = 0
    private var _num: Int = 0 { didSet { numSetCallCount += 1 } }
    public var num: Int {
        get { return _num }
        set { _num = newValue }
    }
    
    public var rateSetCallCount = 0
    private var _rate: Double = 0.0 { didSet { rateSetCallCount += 1 } }
    public var rate: Double {
        get { return _rate }
        set { _rate = newValue }
    }
}
"""

let protocolWithInitResultMock = """

public class HasInitMock: HasInit {
    private var _arg: String!
    public init() { }
    public init(order: Int = 0, num: Int = 0, rate: Double = 0.0) {
        self.order = order
        self.num = num
        self.rate = rate
    }
    required public init(arg: String = "") {
        self._arg = arg
    }
    required public init(order: Int) {
        self._order = order

    }
    public var orderSetCallCount = 0
    private var _order: Int = 0 { didSet { orderSetCallCount += 1 } }
    public var order: Int {
        get { return _order }
        set { _order = newValue }
    }
    public var numSetCallCount = 0
    private var _num: Int = 0 { didSet { numSetCallCount += 1 } }
    public var num: Int {
        get { return _num }
        set { _num = newValue }
    }

    public var rateSetCallCount = 0
    private var _rate: Double = 0.0 { didSet { rateSetCallCount += 1 } }
    public var rate: Double {
        get { return _rate }
        set { _rate = newValue }
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
        self._num = arg
        self._rate = rate
    }
    
     public private(set) var numSetCallCount = 0
       private var _num: Int = 0 { didSet { numSetCallCount += 1 } }
       public var num: Int {
           get { return _num }
           set { _num = newValue }
       }

       public private(set) var rateSetCallCount = 0
       private var _rate: Double = 0.0 { didSet { rateSetCallCount += 1 } }
       public var rate: Double {
           get { return _rate }
           set { _rate = newValue }
       }
}

"""

let simpleInitResultMock = """
import Foundation

public class CurrentMock: Current {
    public init() { }
    public init(title: String = "", num: Int = 0, rate: Double = 0.0) {
        self.title = title
        self.num = num
        self.rate = rate
    }


    public private(set) var titleSetCallCount = 0
    public var title: String = "" { didSet { titleSetCallCount += 1 } }
    
     public private(set) var numSetCallCount = 0
       private var _num: Int = 0 { didSet { numSetCallCount += 1 } }
       public var num: Int {
           get { return _num }
           set { _num = newValue }
       }
       public private(set) var rateSetCallCount = 0
       private var _rate: Double = 0.0 { didSet { rateSetCallCount += 1 } }
       public var rate: Double {
           get { return _rate }
           set { _rate = newValue }
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


let nonSimpleInitVarsMock = """



public class ForcastUpdatingMock: ForcastUpdating {
        private var _checkBlock: ForcastCheckBlock!
    private var _dataStream: DataStream!
    public init() { }
    required public init(checkBlock: @escaping ForcastCheckBlock, dataStream: DataStream) {
        self._checkBlock = checkBlock
        self._dataStream = dataStream
    }


    public private(set) var enabledCallCount = 0
    public var enabledHandler: (() -> (Bool))?
    public func enabled() -> Bool {
        enabledCallCount += 1
        if let enabledHandler = enabledHandler {
            return enabledHandler()
        }
        return false
    }

    public private(set) var forcastLoaderCallCount = 0
    public var forcastLoaderHandler: (() -> (ForcastLoading?))?
    public func forcastLoader() -> ForcastLoading? {
        forcastLoaderCallCount += 1
        if let forcastLoaderHandler = forcastLoaderHandler {
            return forcastLoaderHandler()
        }
        return nil
    }

    public private(set) var fetchInfoCallCount = 0
    public var fetchInfoHandler: ((URL, @escaping (String?, URL?) -> ()) -> ())?
    public func fetchInfo(fromItmsURL itmsURL: URL, completionHandler: @escaping (String?, URL?) -> ())  {
        fetchInfoCallCount += 1
        if let fetchInfoHandler = fetchInfoHandler {
            fetchInfoHandler(itmsURL, completionHandler)
        }
        
    }
}
"""

