import MockoloFramework

let actorProtocol =
"""
/// \(String.mockAnnotation)
protocol Foo: Actor {
    func foo(arg: String) async -> Result<String, Error>
    var bar: Int { get }
}
"""

let actorProtocolMock =
"""
actor FooMock: Foo {
    init() { }
    init(bar: Int = 0) {
        self.bar = bar
    }


    private(set) var fooCallCount = 0
    var fooHandler: ((String) async -> (Result<String, Error>))?
    func foo(arg: String) async -> Result<String, Error> {
        fooCallCount += 1
        if let fooHandler = fooHandler {
            return await fooHandler(arg)
        }
        fatalError("fooHandler returns can't have a default value thus its handler must be set")
    }

    private(set) var barSetCallCount = 0
    var bar: Int = 0 { didSet { barSetCallCount += 1 } }
}
"""
