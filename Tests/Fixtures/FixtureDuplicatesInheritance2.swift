import SwiftMockGenCore

let duplicateSigInheritance2 = """
/// \(String.mockAnnotation)
protocol Foo {
func update(arg: Int)
}

/// \(String.mockAnnotation)
protocol Bar: Foo {
func update(arg: Int)
}
"""

let duplicateSigInheritanceMock2 = """
class FooMock: Foo {

init() {

}

var updateCallCount = 0
var updateHandler: ((Int) -> ())?
func update(arg: Int)  {
updateCallCount += 1
if let updateHandler = updateHandler {
return updateHandler(arg)
}

}
}

class BarMock: Bar {

init() {

}

var updateCallCount = 0
var updateHandler: ((Int) -> ())?
func update(arg: Int)  {
updateCallCount += 1
if let updateHandler = updateHandler {
return updateHandler(arg)
}

}
}

"""
