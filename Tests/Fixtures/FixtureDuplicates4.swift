import MockoloFramework

let duplicates4 =
"""
/// \(String.mockAnnotation)
protocol SomeVC {
func popViewController(viewController: UIViewController)
func popViewController()
}
"""

let duplicatesMock4 =
"""
class SomeVCMock: SomeVC {

init() {

}

var popViewControllerCallCount = 0
var popViewControllerHandler: ((UIViewController) -> ())?
func popViewController(viewController: UIViewController)  {
popViewControllerCallCount += 1
if let popViewControllerHandler = popViewControllerHandler {
return popViewControllerHandler(viewController)
}

}
var popViewController1CallCount = 0
var popViewController1Handler: (() -> ())?
func popViewController()  {
popViewController1CallCount += 1
if let popViewController1Handler = popViewController1Handler {
return popViewController1Handler()
}

}
}
"""

