import MockoloFramework


let rxSubjects = """
/// \(String.mockAnnotation)
public protocol Foo: AnyObject {
    var someBehavior: BehaviorSubject<String> { get }
    var someReply: ReplaySubject<String> { get }
    var someVariable: Variable<Bool> { get }
    var someBar: Bar { get }
}
"""

let rxSubjectsParent = """
public class BarMock: Bar {
    public init() {}
}
"""

let rxSubjectsMock = """
public class FooMock: Foo {
    public init() { }
    public init(someBehavior: BehaviorSubject<String>, someReply: ReplaySubject<String> = ReplaySubject<String>.create(bufferSize: 1), someVariable: Variable<Bool>, someBar: Bar = BarMock()) {
        self._someBehavior = someBehavior
        self.someReply = someReply
        self._someVariable = someVariable
        self.someBar = someBar
    }

    public private(set) var someBehaviorSetCallCount = 0
    private var _someBehavior: BehaviorSubject<String>!  { didSet { someBehaviorSetCallCount += 1 } }
    public var someBehavior: BehaviorSubject<String> {
        get { return _someBehavior }
        set { _someBehavior = newValue }
    }

    public private(set) var someReplySetCallCount = 0
    public var someReply: ReplaySubject<String> = ReplaySubject<String>.create(bufferSize: 1) { didSet { someReplySetCallCount += 1 } }

    public private(set) var someVariableSetCallCount = 0
    private var _someVariable: Variable<Bool>!  { didSet { someVariableSetCallCount += 1 } }
    public var someVariable: Variable<Bool> {
        get { return _someVariable }
        set { _someVariable = newValue }
    }

    public private(set) var someBarSetCallCount = 0
    public var someBar: Bar = BarMock() { didSet { someBarSetCallCount += 1 } }
}
"""

let rx = """
/// \(String.mockAnnotation)(rx: attachedRouter = BehaviorSubject)
protocol TaskRouting: BaseRouting {
    var attachedRouter: Observable<Bool> { get }
    func routeToFoo() -> Observable<()>
}

"""

let rxMock = """
class TaskRoutingMock: TaskRouting {
    init() { }
    init(attachedRouter: Observable<Bool> = BehaviorSubject<Bool>(value: false)) {
        self.attachedRouter = attachedRouter
    }
    private(set) var attachedRouterSubjectSetCallCount = 0
    var _attachedRouter: Observable<Bool>? { didSet { attachedRouterSubjectSetCallCount += 1 } }
    var attachedRouterSubject = BehaviorSubject<Bool>(value: false) { didSet { attachedRouterSubjectSetCallCount += 1 } }
    var attachedRouter: Observable<Bool> {
        get { return _attachedRouter ?? attachedRouterSubject }
        set { if let val = newValue as? BehaviorSubject<Bool> { attachedRouterSubject = val } else { _attachedRouter = newValue } }
    }
    private(set) var routeToFooCallCount = 0
    var routeToFooHandler: (() -> (Observable<()>))?
    func routeToFoo() -> Observable<()> {
        routeToFooCallCount += 1
        if let routeToFooHandler = routeToFooHandler {
            return routeToFooHandler()
        }
        return Observable<()>.empty()
    }
}

"""


let rxObservables = """
/// \(String.mockAnnotation)(rx: nameStream = BehaviorSubject; integerStream = ReplaySubject)
protocol RxVar {
    var isEnabled: Observable<Bool> { get }
    var nameStream: Observable<[EMobilitySearchVehicle]> { get }
    var integerStream: Observable<Int> { get }
}
"""

let rxObservablesMock = """

class RxVarMock: RxVar {
    init() { }
    init(isEnabled: Observable<Bool> = PublishSubject<Bool>(), nameStream: Observable<[EMobilitySearchVehicle]> = BehaviorSubject<[EMobilitySearchVehicle]>(value: [EMobilitySearchVehicle]()), integerStream: Observable<Int> = ReplaySubject<Int>.create(bufferSize: 1)) {
        self.isEnabled = isEnabled
        self.nameStream = nameStream
        self.integerStream = integerStream
    }
    private(set) var isEnabledSubjectSetCallCount = 0
    var _isEnabled: Observable<Bool>? { didSet { isEnabledSubjectSetCallCount += 1 } }
    var isEnabledSubject = PublishSubject<Bool>() { didSet { isEnabledSubjectSetCallCount += 1 } }
    var isEnabled: Observable<Bool> {
        get { return _isEnabled ?? isEnabledSubject }
        set { if let val = newValue as? PublishSubject<Bool> { isEnabledSubject = val } else { _isEnabled = newValue } }
    }
    private(set) var nameStreamSubjectSetCallCount = 0
    var _nameStream: Observable<[EMobilitySearchVehicle]>? { didSet { nameStreamSubjectSetCallCount += 1 } }
    var nameStreamSubject = BehaviorSubject<[EMobilitySearchVehicle]>(value: [EMobilitySearchVehicle]()) { didSet { nameStreamSubjectSetCallCount += 1 } }
    var nameStream: Observable<[EMobilitySearchVehicle]> {
        get { return _nameStream ?? nameStreamSubject }
        set { if let val = newValue as? BehaviorSubject<[EMobilitySearchVehicle]> { nameStreamSubject = val } else { _nameStream = newValue } }
    }
    private(set) var integerStreamSubjectSetCallCount = 0
    var _integerStream: Observable<Int>? { didSet { integerStreamSubjectSetCallCount += 1 } }
    var integerStreamSubject = ReplaySubject<Int>.create(bufferSize: 1) { didSet { integerStreamSubjectSetCallCount += 1 } }
    var integerStream: Observable<Int> {
        get { return _integerStream ?? integerStreamSubject }
        set { if let val = newValue as? ReplaySubject<Int> { integerStreamSubject = val } else { _integerStream = newValue } }
    }
}


"""

let rxVarInherited =
"""
/// \(String.mockAnnotation)(rx: all = BehaviorSubject)
public protocol X {
    var myKey: Observable<SomeKey?> { get }
}

/// \(String.mockAnnotation)
public protocol Y: X {
    func update(with key: SomeKey)
}
"""

let rxVarInheritedMock = """


public class XMock: X {
    public init() { }
    public init(myKey: Observable<SomeKey?> = BehaviorSubject<SomeKey?>(value: nil)) {
        self.myKey = myKey
    }
    public private(set) var myKeySubjectSetCallCount = 0
    var _myKey: Observable<SomeKey?>? { didSet { myKeySubjectSetCallCount += 1 } }
    public var myKeySubject = BehaviorSubject<SomeKey?>(value: nil) { didSet { myKeySubjectSetCallCount += 1 } }
    public var myKey: Observable<SomeKey?> {
        get { return _myKey ?? myKeySubject }
        set { if let val = newValue as? BehaviorSubject<SomeKey?> { myKeySubject = val } else { _myKey = newValue } }
    }
}

public class YMock: Y {
    public init() { }
    public init(myKey: Observable<SomeKey?> = PublishSubject<SomeKey?>()) {
        self.myKey = myKey
    }
    public private(set) var myKeySubjectSetCallCount = 0
    var _myKey: Observable<SomeKey?>? { didSet { myKeySubjectSetCallCount += 1 } }
    public var myKeySubject = BehaviorSubject<SomeKey?>(value: nil) { didSet { myKeySubjectSetCallCount += 1 } }
    public var myKey: Observable<SomeKey?> {
        get { return _myKey ?? myKeySubject }
        set { if let val = newValue as? BehaviorSubject<SomeKey?> { myKeySubject = val } else { _myKey = newValue } }
    }
    public private(set) var updateCallCount = 0
    public var updateHandler: ((SomeKey) -> ())?
    public func update(with key: SomeKey)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler(key)
        }

    }
}


"""



let rxMultiParents =
"""
/// \(String.mockAnnotation)
public protocol TasksStream: BaseTasksStream {
    func update(tasks: Tasks)
}

public protocol BaseTasksStream: BaseTaskScopeListStream, WorkTaskScopeListStream, StateStream, OnlineStream, CompletionTasksStream, WorkStateStream {
    var tasks: Observable<Tasks> { get }
}

/// \(String.mockAnnotation)(rx: all = ReplaySubject)
public protocol BaseTaskScopeListStream: AnyObject {
    var taskScopes: Observable<[TaskScope]> { get }
}

/// \(String.mockAnnotation)(rx: all = ReplaySubject)
public protocol WorkTaskScopeListStream: AnyObject {
    var workTaskScopes: Observable<[TaskScope]> { get }
}

/// \(String.mockAnnotation)
public protocol OnlineStream: AnyObject {
    var online: Observable<Bool> { get }
}
/// \(String.mockAnnotation)
public protocol StateStream: AnyObject {
    var state: Observable<State> { get }
}

/// \(String.mockAnnotation)(rx: all = BehaviorSubject)
public protocol WorkStateStream: AnyObject {
    var isOnJob: Observable<Bool> { get }
}

/// \(String.mockAnnotation)(rx: all = BehaviorSubject)
public protocol CompletionTasksStream: AnyObject {
    var completionTasks: Observable<[CompletionTask]> { get }
}
"""

let rxMultiParentsMock = """
public class TasksStreamMock: TasksStream {
    public init() { }
    public init(tasks: Observable<Tasks> = PublishSubject<Tasks>(), taskScopes: Observable<[TaskScope]> = PublishSubject<[TaskScope]>(), workTaskScopes: Observable<[TaskScope]> = PublishSubject<[TaskScope]>(), online: Observable<Bool> = PublishSubject<Bool>(), state: Observable<State> = PublishSubject<State>(), isOnJob: Observable<Bool> = PublishSubject<Bool>(), completionTasks: Observable<[CompletionTask]> = PublishSubject<[CompletionTask]>()) {
        self.tasks = tasks
        self.taskScopes = taskScopes
        self.workTaskScopes = workTaskScopes
        self.online = online
        self.state = state
        self.isOnJob = isOnJob
        self.completionTasks = completionTasks
    }

    public private(set) var updateCallCount = 0
    public var updateHandler: ((Tasks) -> ())?
    public func update(tasks: Tasks)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler(tasks)
        }

    }
    private var tasksSubjectKind = 0
    public private(set) var tasksSubjectSetCallCount = 0
    public var tasksSubject = PublishSubject<Tasks>() { didSet { tasksSubjectSetCallCount += 1 } }
    public var tasksReplaySubject = ReplaySubject<Tasks>.create(bufferSize: 1) { didSet { tasksSubjectSetCallCount += 1 } }
    public var tasksBehaviorSubject: BehaviorSubject<Tasks>! { didSet { tasksSubjectSetCallCount += 1 } }
    public var _tasks: Observable<Tasks>! { didSet { tasksSubjectSetCallCount += 1 } }
    public var tasks: Observable<Tasks> {
        get {
            if tasksSubjectKind == 0 {
                return tasksSubject
            } else if tasksSubjectKind == 1 {
                return tasksBehaviorSubject
            } else if tasksSubjectKind == 2 {
                return tasksReplaySubject
            } else {
                return _tasks
            }
        }
        set {
            if let val = newValue as? PublishSubject<Tasks> {
                tasksSubject = val
                tasksSubjectKind = 0
            } else if let val = newValue as? BehaviorSubject<Tasks> {
                tasksBehaviorSubject = val
                tasksSubjectKind = 1
            } else if let val = newValue as? ReplaySubject<Tasks> {
                tasksReplaySubject = val
                tasksSubjectKind = 2
            } else {
                _tasks = newValue
                tasksSubjectKind = 3
            }
        }
    }

    public private(set) var taskScopesSubjectSetCallCount = 0
    var _taskScopes: Observable<[TaskScope]>? { didSet { taskScopesSubjectSetCallCount += 1 } }
    public var taskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { taskScopesSubjectSetCallCount += 1 } }
    public var taskScopes: Observable<[TaskScope]> {
        get { return _taskScopes ?? taskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { taskScopesSubject = val } else { _taskScopes = newValue } }
    }

    public private(set) var workTaskScopesSubjectSetCallCount = 0
    var _workTaskScopes: Observable<[TaskScope]>? { didSet { workTaskScopesSubjectSetCallCount += 1 } }
    public var workTaskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { workTaskScopesSubjectSetCallCount += 1 } }
    public var workTaskScopes: Observable<[TaskScope]> {
        get { return _workTaskScopes ?? workTaskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { workTaskScopesSubject = val } else { _workTaskScopes = newValue } }
    }
    private var onlineSubjectKind = 0
    public private(set) var onlineSubjectSetCallCount = 0
    public var onlineSubject = PublishSubject<Bool>() { didSet { onlineSubjectSetCallCount += 1 } }
    public var onlineReplaySubject = ReplaySubject<Bool>.create(bufferSize: 1) { didSet { onlineSubjectSetCallCount += 1 } }
    public var onlineBehaviorSubject: BehaviorSubject<Bool>! { didSet { onlineSubjectSetCallCount += 1 } }
    public var _online: Observable<Bool>! { didSet { onlineSubjectSetCallCount += 1 } }
    public var online: Observable<Bool> {
        get {
            if onlineSubjectKind == 0 {
                return onlineSubject
            } else if onlineSubjectKind == 1 {
                return onlineBehaviorSubject
            } else if onlineSubjectKind == 2 {
                return onlineReplaySubject
            } else {
                return _online
            }
        }
        set {
            if let val = newValue as? PublishSubject<Bool> {
                onlineSubject = val
                onlineSubjectKind = 0
            } else if let val = newValue as? BehaviorSubject<Bool> {
                onlineBehaviorSubject = val
                onlineSubjectKind = 1
            } else if let val = newValue as? ReplaySubject<Bool> {
                onlineReplaySubject = val
                onlineSubjectKind = 2
            } else {
                _online = newValue
                onlineSubjectKind = 3
            }
        }
    }
    private var stateSubjectKind = 0
    public private(set) var stateSubjectSetCallCount = 0
    public var stateSubject = PublishSubject<State>() { didSet { stateSubjectSetCallCount += 1 } }
    public var stateReplaySubject = ReplaySubject<State>.create(bufferSize: 1) { didSet { stateSubjectSetCallCount += 1 } }
    public var stateBehaviorSubject: BehaviorSubject<State>! { didSet { stateSubjectSetCallCount += 1 } }
    public var _state: Observable<State>! { didSet { stateSubjectSetCallCount += 1 } }
    public var state: Observable<State> {
        get {
            if stateSubjectKind == 0 {
                return stateSubject
            } else if stateSubjectKind == 1 {
                return stateBehaviorSubject
            } else if stateSubjectKind == 2 {
                return stateReplaySubject
            } else {
                return _state
            }
        }
        set {
            if let val = newValue as? PublishSubject<State> {
                stateSubject = val
                stateSubjectKind = 0
            } else if let val = newValue as? BehaviorSubject<State> {
                stateBehaviorSubject = val
                stateSubjectKind = 1
            } else if let val = newValue as? ReplaySubject<State> {
                stateReplaySubject = val
                stateSubjectKind = 2
            } else {
                _state = newValue
                stateSubjectKind = 3
            }
        }
    }

    public private(set) var isOnJobSubjectSetCallCount = 0
    var _isOnJob: Observable<Bool>? { didSet { isOnJobSubjectSetCallCount += 1 } }
    public var isOnJobSubject = BehaviorSubject<Bool>(value: false) { didSet { isOnJobSubjectSetCallCount += 1 } }
    public var isOnJob: Observable<Bool> {
        get { return _isOnJob ?? isOnJobSubject }
        set { if let val = newValue as? BehaviorSubject<Bool> { isOnJobSubject = val } else { _isOnJob = newValue } }
    }

    public private(set) var completionTasksSubjectSetCallCount = 0
    var _completionTasks: Observable<[CompletionTask]>? { didSet { completionTasksSubjectSetCallCount += 1 } }
    public var completionTasksSubject = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]()) { didSet { completionTasksSubjectSetCallCount += 1 } }
    public var completionTasks: Observable<[CompletionTask]> {
        get { return _completionTasks ?? completionTasksSubject }
        set { if let val = newValue as? BehaviorSubject<[CompletionTask]> { completionTasksSubject = val } else { _completionTasks = newValue } }
    }
}

public class BaseTaskScopeListStreamMock: BaseTaskScopeListStream {
    public init() { }
    public init(taskScopes: Observable<[TaskScope]> = ReplaySubject<[TaskScope]>.create(bufferSize: 1)) {
        self.taskScopes = taskScopes
    }

    public private(set) var taskScopesSubjectSetCallCount = 0
    var _taskScopes: Observable<[TaskScope]>? { didSet { taskScopesSubjectSetCallCount += 1 } }
    public var taskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { taskScopesSubjectSetCallCount += 1 } }
    public var taskScopes: Observable<[TaskScope]> {
        get { return _taskScopes ?? taskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { taskScopesSubject = val } else { _taskScopes = newValue } }
    }
}

public class WorkTaskScopeListStreamMock: WorkTaskScopeListStream {
    public init() { }
    public init(workTaskScopes: Observable<[TaskScope]> = ReplaySubject<[TaskScope]>.create(bufferSize: 1)) {
        self.workTaskScopes = workTaskScopes
    }

    public private(set)  var workTaskScopesSubjectSetCallCount = 0
    var _workTaskScopes: Observable<[TaskScope]>? { didSet { workTaskScopesSubjectSetCallCount += 1 } }
    public var workTaskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { workTaskScopesSubjectSetCallCount += 1 } }
    public var workTaskScopes: Observable<[TaskScope]> {
        get { return _workTaskScopes ?? workTaskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { workTaskScopesSubject = val } else { _workTaskScopes = newValue } }
    }
}

public class OnlineStreamMock: OnlineStream {
    public init() { }
    public init(online: Observable<Bool> = PublishSubject<Bool>()) {
        self.online = online
    }
    private var onlineSubjectKind = 0
    public private(set) var onlineSubjectSetCallCount = 0
    public var onlineSubject = PublishSubject<Bool>() { didSet { onlineSubjectSetCallCount += 1 } }
    public var onlineReplaySubject = ReplaySubject<Bool>.create(bufferSize: 1) { didSet { onlineSubjectSetCallCount += 1 } }
    public var onlineBehaviorSubject: BehaviorSubject<Bool>! { didSet { onlineSubjectSetCallCount += 1 } }
    public var _online: Observable<Bool>! { didSet { onlineSubjectSetCallCount += 1 } }
    public var online: Observable<Bool> {
        get {
            if onlineSubjectKind == 0 {
                return onlineSubject
            } else if onlineSubjectKind == 1 {
                return onlineBehaviorSubject
            } else if onlineSubjectKind == 2 {
                return onlineReplaySubject
            } else {
                return _online
            }
        }
        set {
            if let val = newValue as? PublishSubject<Bool> {
                onlineSubject = val
                onlineSubjectKind = 0
            } else if let val = newValue as? BehaviorSubject<Bool> {
                onlineBehaviorSubject = val
                onlineSubjectKind = 1
            } else if let val = newValue as? ReplaySubject<Bool> {
                onlineReplaySubject = val
                onlineSubjectKind = 2
            } else {
                _online = newValue
                onlineSubjectKind = 3
            }
        }
    }
}

public class StateStreamMock: StateStream {
    public init() { }
    public init(state: Observable<State> = PublishSubject<State>()) {
        self.state = state
    }
    private var stateSubjectKind = 0
    public private(set) var stateSubjectSetCallCount = 0
    public var stateSubject = PublishSubject<State>() { didSet { stateSubjectSetCallCount += 1 } }
    public var stateReplaySubject = ReplaySubject<State>.create(bufferSize: 1) { didSet { stateSubjectSetCallCount += 1 } }
    public var stateBehaviorSubject: BehaviorSubject<State>! { didSet { stateSubjectSetCallCount += 1 } }
    public var _state: Observable<State>! { didSet { stateSubjectSetCallCount += 1 } }
    public var state: Observable<State> {
        get {
            if stateSubjectKind == 0 {
                return stateSubject
            } else if stateSubjectKind == 1 {
                return stateBehaviorSubject
            } else if stateSubjectKind == 2 {
                return stateReplaySubject
            } else {
                return _state
            }
        }
        set {
            if let val = newValue as? PublishSubject<State> {
                stateSubject = val
                stateSubjectKind = 0
            } else if let val = newValue as? BehaviorSubject<State> {
                stateBehaviorSubject = val
                stateSubjectKind = 1
            } else if let val = newValue as? ReplaySubject<State> {
                stateReplaySubject = val
                stateSubjectKind = 2
            } else {
                _state = newValue
                stateSubjectKind = 3
            }
        }
    }
}

public class WorkStateStreamMock: WorkStateStream {
    public init() { }
    public init(isOnJob: Observable<Bool> = BehaviorSubject<Bool>(value: false)) {
        self.isOnJob = isOnJob
    }

    public private(set) var isOnJobSubjectSetCallCount = 0
    var _isOnJob: Observable<Bool>? { didSet { isOnJobSubjectSetCallCount += 1 } }
    public var isOnJobSubject = BehaviorSubject<Bool>(value: false) { didSet { isOnJobSubjectSetCallCount += 1 } }
    public var isOnJob: Observable<Bool> {
        get { return _isOnJob ?? isOnJobSubject }
        set { if let val = newValue as? BehaviorSubject<Bool> { isOnJobSubject = val } else { _isOnJob = newValue } }
    }
}

public class CompletionTasksStreamMock: CompletionTasksStream {
    public init() { }
    public init(completionTasks: Observable<[CompletionTask]> = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]())) {
        self.completionTasks = completionTasks
    }

    public private(set) var completionTasksSubjectSetCallCount = 0
    var _completionTasks: Observable<[CompletionTask]>? { didSet { completionTasksSubjectSetCallCount += 1 } }
    public var completionTasksSubject = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]()) { didSet { completionTasksSubjectSetCallCount += 1 } }
    public var completionTasks: Observable<[CompletionTask]> {
        get { return _completionTasks ?? completionTasksSubject }
        set { if let val = newValue as? BehaviorSubject<[CompletionTask]> { completionTasksSubject = val } else { _completionTasks = newValue } }
    }
}
"""

let rxMultiParentsMockObservable = """

public class TasksStreamMock: TasksStream {
    public init() { }
    public init(tasks: Observable<Tasks> = PublishSubject<Tasks>(), taskScopes: Observable<[TaskScope]> = PublishSubject<[TaskScope]>(), workTaskScopes: Observable<[TaskScope]> = PublishSubject<[TaskScope]>(), online: Observable<Bool> = PublishSubject<Bool>(), state: Observable<State> = PublishSubject<State>(), isOnJob: Observable<Bool> = PublishSubject<Bool>(), completionTasks: Observable<[CompletionTask]> = PublishSubject<[CompletionTask]>()) {
        self.tasks = tasks
        self.taskScopes = taskScopes
        self.workTaskScopes = workTaskScopes
        self.online = online
        self.state = state
        self.isOnJob = isOnJob
        self.completionTasks = completionTasks
    }
    public private(set) var updateCallCount = 0
    public var updateHandler: ((Tasks) -> ())?
    public func update(tasks: Tasks)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler(tasks)
        }

    }
    public var tasksSubjectSetCallCount: Int { return self._tasks.callCount }
    public var tasksSubject: PublishSubject<Tasks> { return self._tasks.publishSubject }
    public var tasksReplaySubject: ReplaySubject<Tasks> { return self._tasks.replaySubject }
    public var tasksBehaviorSubject: BehaviorSubject<Tasks> { return self._tasks.behaviorSubject }
    @MockObservable(unwrapped: Observable<Tasks>.empty()) public var tasks: Observable<Tasks>
    public private(set) var taskScopesSubjectSetCallCount = 0
    var _taskScopes: Observable<[TaskScope]>? { didSet { taskScopesSubjectSetCallCount += 1 } }
    public var taskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { taskScopesSubjectSetCallCount += 1 } }
    public var taskScopes: Observable<[TaskScope]> {
        get { return _taskScopes ?? taskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { taskScopesSubject = val } else { _taskScopes = newValue } }
    }
    public private(set) var workTaskScopesSubjectSetCallCount = 0
    var _workTaskScopes: Observable<[TaskScope]>? { didSet { workTaskScopesSubjectSetCallCount += 1 } }
    public var workTaskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { workTaskScopesSubjectSetCallCount += 1 } }
    public var workTaskScopes: Observable<[TaskScope]> {
        get { return _workTaskScopes ?? workTaskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { workTaskScopesSubject = val } else { _workTaskScopes = newValue } }
    }
    public var onlineSubjectSetCallCount: Int { return self._online.callCount }
    public var onlineSubject: PublishSubject<Bool> { return self._online.publishSubject }
    public var onlineReplaySubject: ReplaySubject<Bool> { return self._online.replaySubject }
    public var onlineBehaviorSubject: BehaviorSubject<Bool> { return self._online.behaviorSubject }
    @MockObservable(unwrapped: Observable<Bool>.empty()) public var online: Observable<Bool>
    public var stateSubjectSetCallCount: Int { return self._state.callCount }
    public var stateSubject: PublishSubject<State> { return self._state.publishSubject }
    public var stateReplaySubject: ReplaySubject<State> { return self._state.replaySubject }
    public var stateBehaviorSubject: BehaviorSubject<State> { return self._state.behaviorSubject }
    @MockObservable(unwrapped: Observable<State>.empty()) public var state: Observable<State>
    public private(set) var isOnJobSubjectSetCallCount = 0
    var _isOnJob: Observable<Bool>? { didSet { isOnJobSubjectSetCallCount += 1 } }
    public var isOnJobSubject = BehaviorSubject<Bool>(value: false) { didSet { isOnJobSubjectSetCallCount += 1 } }
    public var isOnJob: Observable<Bool> {
        get { return _isOnJob ?? isOnJobSubject }
        set { if let val = newValue as? BehaviorSubject<Bool> { isOnJobSubject = val } else { _isOnJob = newValue } }
    }
    public private(set) var completionTasksSubjectSetCallCount = 0
    var _completionTasks: Observable<[CompletionTask]>? { didSet { completionTasksSubjectSetCallCount += 1 } }
    public var completionTasksSubject = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]()) { didSet { completionTasksSubjectSetCallCount += 1 } }
    public var completionTasks: Observable<[CompletionTask]> {
        get { return _completionTasks ?? completionTasksSubject }
        set { if let val = newValue as? BehaviorSubject<[CompletionTask]> { completionTasksSubject = val } else { _completionTasks = newValue } }
    }
}

public class BaseTaskScopeListStreamMock: BaseTaskScopeListStream {
    public init() { }
    public init(taskScopes: Observable<[TaskScope]> = ReplaySubject<[TaskScope]>.create(bufferSize: 1)) {
        self.taskScopes = taskScopes
    }
    public private(set) var taskScopesSubjectSetCallCount = 0
    var _taskScopes: Observable<[TaskScope]>? { didSet { taskScopesSubjectSetCallCount += 1 } }
    public var taskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { taskScopesSubjectSetCallCount += 1 } }
    public var taskScopes: Observable<[TaskScope]> {
        get { return _taskScopes ?? taskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { taskScopesSubject = val } else { _taskScopes = newValue } }
    }
}

public class WorkTaskScopeListStreamMock: WorkTaskScopeListStream {
    public init() { }
    public init(workTaskScopes: Observable<[TaskScope]> = ReplaySubject<[TaskScope]>.create(bufferSize: 1)) {
        self.workTaskScopes = workTaskScopes
    }
    public private(set) var workTaskScopesSubjectSetCallCount = 0
    var _workTaskScopes: Observable<[TaskScope]>? { didSet { workTaskScopesSubjectSetCallCount += 1 } }
    public var workTaskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { workTaskScopesSubjectSetCallCount += 1 } }
    public var workTaskScopes: Observable<[TaskScope]> {
        get { return _workTaskScopes ?? workTaskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { workTaskScopesSubject = val } else { _workTaskScopes = newValue } }
    }
}

public class OnlineStreamMock: OnlineStream {
    public init() { }
    public init(online: Observable<Bool> = PublishSubject<Bool>()) {
        self.online = online
    }
    public var onlineSubjectSetCallCount: Int { return self._online.callCount }
    public var onlineSubject: PublishSubject<Bool> { return self._online.publishSubject }
    public var onlineReplaySubject: ReplaySubject<Bool> { return self._online.replaySubject }
    public var onlineBehaviorSubject: BehaviorSubject<Bool> { return self._online.behaviorSubject }
    @MockObservable(unwrapped: Observable<Bool>.empty()) public var online: Observable<Bool>
}

public class StateStreamMock: StateStream {
    public init() { }
    public init(state: Observable<State> = PublishSubject<State>()) {
        self.state = state
    }
    public var stateSubjectSetCallCount: Int { return self._state.callCount }
    public var stateSubject: PublishSubject<State> { return self._state.publishSubject }
    public var stateReplaySubject: ReplaySubject<State> { return self._state.replaySubject }
    public var stateBehaviorSubject: BehaviorSubject<State> { return self._state.behaviorSubject }
    @MockObservable(unwrapped: Observable<State>.empty()) public var state: Observable<State>
}

public class WorkStateStreamMock: WorkStateStream {
    public init() { }
    public init(isOnJob: Observable<Bool> = BehaviorSubject<Bool>(value: false)) {
        self.isOnJob = isOnJob
    }
    public private(set) var isOnJobSubjectSetCallCount = 0
    var _isOnJob: Observable<Bool>? { didSet { isOnJobSubjectSetCallCount += 1 } }
    public var isOnJobSubject = BehaviorSubject<Bool>(value: false) { didSet { isOnJobSubjectSetCallCount += 1 } }
    public var isOnJob: Observable<Bool> {
        get { return _isOnJob ?? isOnJobSubject }
        set { if let val = newValue as? BehaviorSubject<Bool> { isOnJobSubject = val } else { _isOnJob = newValue } }
    }
}

public class CompletionTasksStreamMock: CompletionTasksStream {
    public init() { }
    public init(completionTasks: Observable<[CompletionTask]> = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]())) {
        self.completionTasks = completionTasks
    }
    public private(set) var completionTasksSubjectSetCallCount = 0
    var _completionTasks: Observable<[CompletionTask]>? { didSet { completionTasksSubjectSetCallCount += 1 } }
    public var completionTasksSubject = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]()) { didSet { completionTasksSubjectSetCallCount += 1 } }
    public var completionTasks: Observable<[CompletionTask]> {
        get { return _completionTasks ?? completionTasksSubject }
        set { if let val = newValue as? BehaviorSubject<[CompletionTask]> { completionTasksSubject = val } else { _completionTasks = newValue } }
    }
}

"""

