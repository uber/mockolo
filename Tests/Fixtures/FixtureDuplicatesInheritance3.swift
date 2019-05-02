import MockoloFramework

let duplicateSigInheritance3 = """
/// \(String.mockAnnotation)
protocol Foo {
func update(arg: Int)
}

/// \(String.mockAnnotation)
protocol Bar {
func update(arg: Int)
}

/// \(String.mockAnnotation)
protocol Baz: Foo, Bar {
}
"""

let duplicateSigInheritanceMock3 = """

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

class BazMock: Baz {

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
