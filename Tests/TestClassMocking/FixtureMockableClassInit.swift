import MockoloFramework

let klassInit =
"""
/// \(String.mockAnnotation)
public class Low: Mid {
    var name: String = ""
    public required init(arg: String) {
        super.init(orderId: 1)
        self.name = arg
    }

    public required init(orderId: Int) {
        super.init(orderId: orderId)
    }

    public init(m: Int) {
        super.init(orderId: m)
    }

    convenience public init(n: Int) {
        self.init(m: n)
    }
}

public class Mid: High {
    var what: Double = 0.0
}
"""

let klassInitParent =
"""

public class High {
    var order: Int
    
    public required init(orderId: Int) {
        self.order = orderId
    }
    
    public init(loc: String) {
        self.order = 0
    }
}
"""

let klassInitParentMock =
"""
public class HighMock: High {
    

    public required init(orderId: Int) {
        super.init(orderId: orderId)
        
    }

    public var orderSetCallCount = 0
    var underlyingOrder: Int = 0
    public override var order: Int {
        get { return underlyingOrder }
        set {
            underlyingOrder = newValue
            if _doneInit { orderSetCallCount += 1 }
        }
    }
}

"""

let klassInitMock = """

public class LowMock: Low {
    
    override public init(m: Int = 0) {
        super.init(m: m)
    }
    required public init(arg: String = "") {
        super.init(arg: arg)
    }
    required public init(orderId: Int = 0) {
        super.init(orderId: orderId)
    }

    private(set) var nameSetCallCount = 0
    override var name: String = "" { didSet { nameSetCallCount += 1 } }
}
"""


let klassInitLongerMock = """

public class LowMock: Low {

    override public init(m: Int = 0) {
        super.init(m: m)
    }

    required public init(arg: String = "") {
        super.init(arg: arg)
    }

    required public init(orderId: Int = 0) {
        super.init(orderId: orderId)
    }

    private(set) var nameSetCallCount = 0
    override var name: String = "" { didSet { nameSetCallCount += 1 } }
}
"""
