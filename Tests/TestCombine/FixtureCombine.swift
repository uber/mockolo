 import MockoloFramework

 let combineProtocol = """
/// \(String.mockAnnotation)(combine: dictionaryPublisher = CurrentValueSubject; myPublisher = PassthroughSubject; noDefaultSubjectValue = CurrentValueSubject)
public protocol Foo: AnyObject {
    var myPublisher: AnyPublisher<String, Never> { get }
    var dictionaryPublisher: AnyPublisher<Dictionary<String, String>, Never> { get }
    var noDefaultSubjectValue: AnyPublisher<CustomType, Never> { get }
}
"""

let combineProtocolMock = """
public class FooMock: Foo {
    public init() { }

    public var myPublisher: AnyPublisher<String, Never> { return self.myPublisherSubject.eraseToAnyPublisher() }
    public private(set) var myPublisherSubject = PassthroughSubject<String, Never>()

    public var dictionaryPublisher: AnyPublisher<Dictionary<String, String>, Never> { return self.dictionaryPublisherSubject.eraseToAnyPublisher() }
    public private(set) var dictionaryPublisherSubject = CurrentValueSubject<Dictionary<String, String>, Never>(Dictionary<String, String>())

    public var noDefaultSubjectValue: AnyPublisher<CustomType, Never> { return self.noDefaultSubjectValueSubject.eraseToAnyPublisher() }
    public private(set) var noDefaultSubjectValueSubject = PassthroughSubject<CustomType, Never>()
}
"""

let combinePublishedProtocol = """
/// \(String.mockAnnotation)(combine: myStringPublisher = @Published myString; myIntPublisher = @Published myInt; myCustomTypePublisher = @Published myCustomType; myNonOptionalPublisher = @CustomPropertyWrapper myNonOptional)
public protocol FooPublished {
    var myString: String { get set }
    var myStringPublisher: AnyPublisher<String, Never> { get }
    var myIntPublisher: AnyPublisher<Int, Never> { get }
    var myCustomTypePublisher: AnyPublisher<MyCustomType, Error> { get }
    var myNonOptional: NonOptional { get set }
    var myNonOptionalPublisher: AnyPublisher<NonOptional, Never> { get }
}
"""

let combinePublishedProtocolMock = """
public class FooPublishedMock: FooPublished {
    public init() { }
    public init(myString: String = "", myNonOptional: NonOptional) {
        self.myString = myString
        self._myNonOptional = myNonOptional
    }

    public private(set) var myStringSetCallCount = 0
    @Published public var myString: String = "" { didSet { myStringSetCallCount += 1 } }

    public var myStringPublisher: AnyPublisher<String, Never> { return self.$myString.setFailureType(to: Never.self).eraseToAnyPublisher() }

    public var myIntPublisher: AnyPublisher<Int, Never> { return self.myIntPublisherSubject.eraseToAnyPublisher() }
    public private(set) var myIntPublisherSubject = PassthroughSubject<Int, Never>()

    public var myCustomTypePublisher: AnyPublisher<MyCustomType, Error> { return self.myCustomTypePublisherSubject.eraseToAnyPublisher() }
    public private(set) var myCustomTypePublisherSubject = PassthroughSubject<MyCustomType, Error>()

    public private(set) var myNonOptionalSetCallCount = 0
    @CustomPropertyWrapper private var _myNonOptional: NonOptional!  { didSet { myNonOptionalSetCallCount += 1 } }
    public var myNonOptional: NonOptional {
        get { return _myNonOptional }
        set { _myNonOptional = newValue }
    }

    public var myNonOptionalPublisher: AnyPublisher<NonOptional, Never> { return self.$_myNonOptional.map { $0! }.setFailureType(to: Never.self).eraseToAnyPublisher() }
}
"""

let combineNullableProtocol = """
/// \(String.mockAnnotation)(combine: myStringPublisher = @Published myString; myIntPublisher = @Published myInt; myCustomTypePublisher = @Published myCustomType; myNonOptionalPublisher = @Published myNonOptional)
public protocol FooNullable {
    var myString: String? { get set }
    var myStringPublisher: AnyPublisher<String, Never> { get }
    var myInt: Int { get set }
    var myIntPublisher: AnyPublisher<Int?, Never> { get }
    var myCustomType: MyCustomType? { get set }
    var myCustomTypePublisher: AnyPublisher<MyCustomType?, Error> { get }
    var myNonOptional: NonOptional? { get set }
    var myNonOptionalPublisher: AnyPublisher<NonOptional, Never> { get }
}
"""

let combineNullableProtocolMock = """
public class FooNullableMock: FooNullable {
    public init() { }
    public init(myString: String? = nil, myInt: Int = 0, myCustomType: MyCustomType? = nil, myNonOptional: NonOptional? = nil) {
        self.myString = myString
        self.myInt = myInt
        self.myCustomType = myCustomType
        self.myNonOptional = myNonOptional
    }


    public private(set) var myStringSetCallCount = 0
    @Published public var myString: String? = nil { didSet { myStringSetCallCount += 1 } }

    public var myStringPublisher: AnyPublisher<String, Never> { return self.$myString.map { $0! }.setFailureType(to: Never.self).eraseToAnyPublisher() }

    public private(set) var myIntSetCallCount = 0
    @Published public var myInt: Int = 0 { didSet { myIntSetCallCount += 1 } }

    public var myIntPublisher: AnyPublisher<Int?, Never> { return self.$myInt.map { $0 }.setFailureType(to: Never.self).eraseToAnyPublisher() }

    public private(set) var myCustomTypeSetCallCount = 0
    @Published public var myCustomType: MyCustomType? = nil { didSet { myCustomTypeSetCallCount += 1 } }

    public var myCustomTypePublisher: AnyPublisher<MyCustomType?, Error> { return self.$myCustomType.setFailureType(to: Error.self).eraseToAnyPublisher() }

    public private(set) var myNonOptionalSetCallCount = 0
    @Published public var myNonOptional: NonOptional? = nil { didSet { myNonOptionalSetCallCount += 1 } }

    public var myNonOptionalPublisher: AnyPublisher<NonOptional, Never> { return self.$myNonOptional.map { $0! }.setFailureType(to: Never.self).eraseToAnyPublisher() }
}
"""

let combineMultiParents =
"""
/// \(String.mockAnnotation)
public protocol BaseProtocolA {
    var myStringInBase: String { get set }
}

/// \(String.mockAnnotation)(combine: myIntPublisher = @Published myInt)
public protocol BaseProtocolB {
    var myIntPublisher: AnyPublisher<Int, Error> { get }
    var myOtherPublisher: AnyPublisher<Double, Never> { get }
}

/// \(String.mockAnnotation)(combine: myStringPublisher = @Published myStringInBase)
public protocol Child: BaseProtocolA, BaseProtocolB {
    var myStringPublisher: AnyPublisher<String?, Never> { get }
    var myInt: Int { get set }
}

"""

let combineMultiParentsMock = """
public class BaseProtocolAMock: BaseProtocolA {
    public init() { }
    public init(myStringInBase: String = "") {
        self.myStringInBase = myStringInBase
    }


    public private(set) var myStringInBaseSetCallCount = 0
    public var myStringInBase: String = "" { didSet { myStringInBaseSetCallCount += 1 } }
}

public class BaseProtocolBMock: BaseProtocolB {
    public init() { }


    public var myIntPublisher: AnyPublisher<Int, Error> { return self.myIntPublisherSubject.eraseToAnyPublisher() }
    public private(set) var myIntPublisherSubject = PassthroughSubject<Int, Error>()

    public var myOtherPublisher: AnyPublisher<Double, Never> { return self.myOtherPublisherSubject.eraseToAnyPublisher() }
    public private(set) var myOtherPublisherSubject = PassthroughSubject<Double, Never>()
}

public class ChildMock: Child {
    public init() { }
    public init(myStringInBase: String = "", myInt: Int = 0) {
        self.myStringInBase = myStringInBase
        self.myInt = myInt
    }


    public private(set) var myStringInBaseSetCallCount = 0
    @Published public var myStringInBase: String = "" { didSet { myStringInBaseSetCallCount += 1 } }

    public var myIntPublisher: AnyPublisher<Int, Error> { return self.$myInt.setFailureType(to: Error.self).eraseToAnyPublisher() }

    public var myOtherPublisher: AnyPublisher<Double, Never> { return self.myOtherPublisherSubject.eraseToAnyPublisher() }
    public private(set) var myOtherPublisherSubject = PassthroughSubject<Double, Never>()

    public var myStringPublisher: AnyPublisher<String?, Never> { return self.$myStringInBase.map { $0 }.setFailureType(to: Never.self).eraseToAnyPublisher() }

    public private(set) var myIntSetCallCount = 0
    @Published public var myInt: Int = 0 { didSet { myIntSetCallCount += 1 } }
}
"""

let combineMockContentProtocol = """
/// \(String.mockAnnotation)(combine: myStringPublisher = @Published myStringInBase)
public protocol Child: BaseProtocolA {
    var myStringPublisher: AnyPublisher<String?, Never> { get }
}

"""

let combineMockContentMock = """
public class BaseProtocolAMock: BaseProtocolA {
    public init() { }
    public init(myStringInBase: String = "") {
        self.myStringInBase = myStringInBase
    }

    public var dictionaryPublisher: AnyPublisher<Dictionary<String, String>, Never> { return self.dictionaryPublisherSubject.eraseToAnyPublisher() }
    public private(set) var dictionaryPublisherSubject = CurrentValueSubject<Dictionary<String, String>, Never>(Dictionary<String, String>())

    public private(set) var myStringInBaseSetCallCount = 0
    public var myStringInBase: String = "" { didSet { myStringInBaseSetCallCount += 1 } }
}
"""

let combineMockContentResult = """
public class ChildMock: Child {
    public init() { }
    public init(myStringInBase: String = "") {
        self.myStringInBase = myStringInBase
    }

    public var myStringPublisher: AnyPublisher<String?, Never> { return self.$myStringInBase.map { $0 }.setFailureType(to: Never.self).eraseToAnyPublisher() }

    public var dictionaryPublisher: AnyPublisher<Dictionary<String, String>, Never> { return self.dictionaryPublisherSubject.eraseToAnyPublisher() }
    public private(set) var dictionaryPublisherSubject = CurrentValueSubject<Dictionary<String, String>, Never>(Dictionary<String, String>())

    public private(set) var myStringInBaseSetCallCount = 0
    @Published public var myStringInBase: String = "" { didSet { myStringInBaseSetCallCount += 1 } }
}
"""
