let globalActorProtocol = #Fixture {
    /// @mockable
    @MainActor protocol RootController: AnyObject {
        var viewController: UIViewController { get }
    }

    /// @mockable
    protocol RootBuildable {
        func build() -> RootController
    }

    return {
        class RootControllerMock: RootController {
            init() { }
            init(viewController: UIViewController) {
                self._viewController = viewController
            }

            private var _viewController: UIViewController!
            var viewController: UIViewController {
                get { return _viewController }
                set { _viewController = newValue }
            }
        }

        class RootBuildableMock: RootBuildable {
            init() { }


            private(set) var buildCallCount = 0
            var buildHandler: (() -> RootController)?
            func build() -> RootController {
                buildCallCount += 1
                if let buildHandler = buildHandler {
                    return buildHandler()
                }
                fatalError("buildHandler returns can't have a default value thus its handler must be set")
            }
        }
    }
}
