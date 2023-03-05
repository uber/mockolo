import Foundation

let nameOverride =
"""
/// \(String.mockAnnotation)(override: name = FooMock)
protocol FooProtocol {
    func display()
}
"""

let nameOverrideMock =
"""
class FooMock: FooProtocol {
    init() { }

    private(set) var displayCallCount = 0
    var displayHandler: (() -> ())?
    func display()  {
        displayCallCount += 1
        if let displayHandler = displayHandler {
            displayHandler()
        }
    }
}
"""
