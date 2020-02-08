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
    private var _doneInit = false

    public required init(orderId: Int) {
        super.init(orderId: orderId)
        _doneInit = true
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

let klassInitMock =
    
"""
public class LowMock: Low {
    
    private var _doneInit = false
    
    
    public init(name: String = "", what: Double = 0.0) {
        self.name = name
        self.what = what
        _doneInit = true
    }
    
    var nameSetCallCount = 0
    var underlyingName: String = ""
    override var name: String {
        get { return underlyingName }
        set {
            underlyingName = newValue
            if _doneInit { nameSetCallCount += 1 }
        }
    }
    required public init(arg: String = "") {
        super.init(arg: arg)
        _doneInit = true
    }
    override public init(m: Int = 0) {
        super.init(m: m)
        _doneInit = true
    }
    
    var whatSetCallCount = 0
    var underlyingWhat: Double = 0.0
    override var what: Double {
        get { return underlyingWhat }
        set {
            underlyingWhat = newValue
            if _doneInit { whatSetCallCount += 1 }
        }
    }
}
"""


let klassInitLongerMock =
"""
public class LowMock: Low {
    
    private var _doneInit = false
    
    
    public init(name: String = "", what: Double = 0.0, order: Int = 0) {
        self.name = name
        self.what = what
        self.order = order
        _doneInit = true
    }
    
    var nameSetCallCount = 0
    var underlyingName: String = ""
    override var name: String {
        get { return underlyingName }
        set {
            underlyingName = newValue
            if _doneInit { nameSetCallCount += 1 }
        }
    }
    required public init(arg: String = "") {
        super.init(arg: arg)
        _doneInit = true
    }
    public required init(orderId: Int) {
        super.init(orderId: orderId)
        _doneInit = true
    }
    override public init(m: Int = 0) {
        super.init(m: m)
        _doneInit = true
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
    
    var whatSetCallCount = 0
    var underlyingWhat: Double = 0.0
    override var what: Double {
        get { return underlyingWhat }
        set {
            underlyingWhat = newValue
            if _doneInit { whatSetCallCount += 1 }
        }
    }
}

"""
