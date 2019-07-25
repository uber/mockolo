import MockoloFramework

let overload1 = """
/// \(String.mockAnnotation)
protocol P1: P0 {
}
"""

let overloadParent1 = """

public class P0Mock: P0 {

init() {

}
var updateCallCount = 0
var updateHandler: (([String], Bool, @escaping () -> ()) -> ())?
func update(arg: [String], once: Bool, closure: @escaping () -> ())  {
updateCallCount += 1
if let updateHandler = updateHandler {
return updateHandler(arg, once, closure)
}

}
var updateArgCallCount = 0
var updateArgHandler: (([String], Any, Bool, Any) -> ())?
func update<T>(arg: [String], value: T, once: Bool, closure: @escaping (T) -> ())  {
updateArgCallCount += 1
if let updateArgHandler = updateArgHandler {
return updateArgHandler(arg, value, once, closure)
}

}
}
"""

let overloadMock1 = """
class P1Mock: P1 {

init() {

}
var updateCallCount = 0
var updateHandler: (([String], Bool, @escaping () -> ()) -> ())?
func update(arg: [String], once: Bool, closure: @escaping () -> ())  {
updateCallCount += 1
if let updateHandler = updateHandler {
return updateHandler(arg, once, closure)
}

}
var updateArgCallCount = 0
var updateArgHandler: (([String], Any, Bool, Any) -> ())?
func update<T>(arg: [String], value: T, once: Bool, closure: @escaping (T) -> ())  {
updateArgCallCount += 1
if let updateArgHandler = updateArgHandler {
return updateArgHandler(arg, value, once, closure)
}

}
}
"""
