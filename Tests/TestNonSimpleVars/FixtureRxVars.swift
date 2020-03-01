import MockoloFramework


let rx = """
/// \(String.mockAnnotation)(rx: attachedRouter = BehaviorSubject)
protocol TaskRouting: BaseRouting {
    var attachedRouter: Observable<Bool> { get }
    func routeToFoo() -> Observable<()>
}

"""

let rxMock = """

class TaskRoutingMock: TaskRouting {
    private var _doneInit = false
    
    init() { _doneInit = true }
    init(attachedRouter: Observable<Bool> = BehaviorSubject<Bool>(value: false)) {
        self.attachedRouter = attachedRouter
        _doneInit = true
    }
    var attachedRouterSubjectSetCallCount = 0
    var underlyingAttachedRouter: Observable<Bool>? { didSet { if _doneInit { attachedRouterSubjectSetCallCount += 1 } } }
    var attachedRouterSubject = BehaviorSubject<Bool>(value: false) { didSet { if _doneInit { attachedRouterSubjectSetCallCount += 1 } } }
    var attachedRouter: Observable<Bool> {
        get { return underlyingAttachedRouter ?? attachedRouterSubject }
        set { if let val = newValue as? BehaviorSubject<Bool> { attachedRouterSubject = val } else { underlyingAttachedRouter = newValue } }
    }
    var routeToFooCallCount = 0
    var routeToFooHandler: (() -> (Observable<()>))?
    func routeToFoo() -> Observable<()> {
        routeToFooCallCount += 1
        if let routeToFooHandler = routeToFooHandler {
            return routeToFooHandler()
        }
        return Observable.empty()
    }
}
"""


let rxVarSubjects = """
/// \(String.mockAnnotation)(rx: nameStream = BehaviorSubject; integerStream = ReplaySubject)
protocol RxVar {
    var isEnabled: Observable<Bool> { get }
    var nameStream: Observable<[EMobilitySearchVehicle]> { get }
    var integerStream: Observable<Int> { get }
}
"""

let rxVarSubjectsMock = """

class RxVarMock: RxVar {
    
    private var _doneInit = false
    
    init() { _doneInit = true }
    init(isEnabled: Observable<Bool> = PublishSubject<Bool>(), nameStream: Observable<[EMobilitySearchVehicle]> = BehaviorSubject<[EMobilitySearchVehicle]>(value: [EMobilitySearchVehicle]()), integerStream: Observable<Int> = ReplaySubject<Int>.create(bufferSize: 1)) {
        self.isEnabled = isEnabled
        self.nameStream = nameStream
        self.integerStream = integerStream
        _doneInit = true
    }
    var isEnabledSubjectSetCallCount = 0
    var underlyingIsEnabled: Observable<Bool>? { didSet { if _doneInit { isEnabledSubjectSetCallCount += 1 } } }
    var isEnabledSubject = PublishSubject<Bool>() { didSet { if _doneInit { isEnabledSubjectSetCallCount += 1 } } }
    var isEnabled: Observable<Bool> {
        get { return underlyingIsEnabled ?? isEnabledSubject }
        set { if let val = newValue as? PublishSubject<Bool> { isEnabledSubject = val } else { underlyingIsEnabled = newValue } }
    }
    var nameStreamSubjectSetCallCount = 0
    var underlyingNameStream: Observable<[EMobilitySearchVehicle]>? { didSet { if _doneInit { nameStreamSubjectSetCallCount += 1 } } }
    var nameStreamSubject = BehaviorSubject<[EMobilitySearchVehicle]>(value: [EMobilitySearchVehicle]()) { didSet { if _doneInit { nameStreamSubjectSetCallCount += 1 } } }
    var nameStream: Observable<[EMobilitySearchVehicle]> {
        get { return underlyingNameStream ?? nameStreamSubject }
        set { if let val = newValue as? BehaviorSubject<[EMobilitySearchVehicle]> { nameStreamSubject = val } else { underlyingNameStream = newValue } }
    }
    var integerStreamSubjectSetCallCount = 0
    var underlyingIntegerStream: Observable<Int>? { didSet { if _doneInit { integerStreamSubjectSetCallCount += 1 } } }
    var integerStreamSubject = ReplaySubject<Int>.create(bufferSize: 1) { didSet { if _doneInit { integerStreamSubjectSetCallCount += 1 } } }
    var integerStream: Observable<Int> {
        get { return underlyingIntegerStream ?? integerStreamSubject }
        set { if let val = newValue as? ReplaySubject<Int> { integerStreamSubject = val } else { underlyingIntegerStream = newValue } }
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
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(myKey: Observable<SomeKey?> = BehaviorSubject<SomeKey?>(value: nil)) {
        self.myKey = myKey
        _doneInit = true
    }
    public var myKeySubjectSetCallCount = 0
    var underlyingMyKey: Observable<SomeKey?>? { didSet { if _doneInit { myKeySubjectSetCallCount += 1 } } }
    public var myKeySubject = BehaviorSubject<SomeKey?>(value: nil) { didSet { if _doneInit { myKeySubjectSetCallCount += 1 } } }
    public var myKey: Observable<SomeKey?> {
        get { return underlyingMyKey ?? myKeySubject }
        set { if let val = newValue as? BehaviorSubject<SomeKey?> { myKeySubject = val } else { underlyingMyKey = newValue } }
    }
}

public class YMock: Y {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(myKey: Observable<SomeKey?> = PublishSubject<SomeKey?>()) {
        self.myKey = myKey
        _doneInit = true
    }
    public var myKeySubjectSetCallCount = 0
    var underlyingMyKey: Observable<SomeKey?>? { didSet { if _doneInit { myKeySubjectSetCallCount += 1 } } }
    public var myKeySubject = BehaviorSubject<SomeKey?>(value: nil) { didSet { if _doneInit { myKeySubjectSetCallCount += 1 } } }
    public var myKey: Observable<SomeKey?> {
        get { return underlyingMyKey ?? myKeySubject }
        set { if let val = newValue as? BehaviorSubject<SomeKey?> { myKeySubject = val } else { underlyingMyKey = newValue } }
    }
    public var updateCallCount = 0
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
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(tasks: Observable<Tasks> = PublishSubject<Tasks>(), taskScopes: Observable<[TaskScope]> = PublishSubject<[TaskScope]>(), workTaskScopes: Observable<[TaskScope]> = PublishSubject<[TaskScope]>(), online: Observable<Bool> = PublishSubject<Bool>(), state: Observable<State> = PublishSubject<State>(), isOnJob: Observable<Bool> = PublishSubject<Bool>(), completionTasks: Observable<[CompletionTask]> = PublishSubject<[CompletionTask]>()) {
        self.tasks = tasks
        self.taskScopes = taskScopes
        self.workTaskScopes = workTaskScopes
        self.online = online
        self.state = state
        self.isOnJob = isOnJob
        self.completionTasks = completionTasks
        _doneInit = true
    }
    public var updateCallCount = 0
    public var updateHandler: ((Tasks) -> ())?
    public func update(tasks: Tasks)  {
        updateCallCount += 1
        if let updateHandler = updateHandler {
            updateHandler(tasks)
        }
        
    }
    private var tasksSubjectKind = 0
    public var tasksSubjectSetCallCount = 0
    public var tasksSubject = PublishSubject<Tasks>() { didSet { if _doneInit { tasksSubjectSetCallCount += 1 } } }
    public var tasksReplaySubject = ReplaySubject<Tasks>.create(bufferSize: 1) { didSet { if _doneInit { tasksSubjectSetCallCount += 1 } } }
    public var tasksBehaviorSubject: BehaviorSubject<Tasks>! { didSet { if _doneInit { tasksSubjectSetCallCount += 1 } } }
    public var underlyingTasks: Observable<Tasks>! { didSet { if _doneInit { tasksSubjectSetCallCount += 1 } } }
    public var tasks: Observable<Tasks> {
        get {
            if tasksSubjectKind == 0 { return tasksSubject }
            else if tasksSubjectKind == 1 { return tasksBehaviorSubject }
            else if tasksSubjectKind == 2 { return tasksReplaySubject }
            else { return underlyingTasks }
        }
        set {
            if let val = newValue as? PublishSubject<Tasks> { tasksSubjectKind = 0; tasksSubject = val }
            else if let val = newValue as? BehaviorSubject<Tasks> { tasksSubjectKind = 1; tasksBehaviorSubject = val }
            else if let val = newValue as? ReplaySubject<Tasks> { tasksSubjectKind = 2; tasksReplaySubject = val }
            else { tasksSubjectKind = 3; underlyingTasks = newValue }
        }
    }
    public var taskScopesSubjectSetCallCount = 0
    var underlyingTaskScopes: Observable<[TaskScope]>? { didSet { if _doneInit { taskScopesSubjectSetCallCount += 1 } } }
    public var taskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { if _doneInit { taskScopesSubjectSetCallCount += 1 } } }
    public var taskScopes: Observable<[TaskScope]> {
        get { return underlyingTaskScopes ?? taskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { taskScopesSubject = val } else { underlyingTaskScopes = newValue } }
    }
    public var workTaskScopesSubjectSetCallCount = 0
    var underlyingWorkTaskScopes: Observable<[TaskScope]>? { didSet { if _doneInit { workTaskScopesSubjectSetCallCount += 1 } } }
    public var workTaskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { if _doneInit { workTaskScopesSubjectSetCallCount += 1 } } }
    public var workTaskScopes: Observable<[TaskScope]> {
        get { return underlyingWorkTaskScopes ?? workTaskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { workTaskScopesSubject = val } else { underlyingWorkTaskScopes = newValue } }
    }
    private var onlineSubjectKind = 0
    public var onlineSubjectSetCallCount = 0
    public var onlineSubject = PublishSubject<Bool>() { didSet { if _doneInit { onlineSubjectSetCallCount += 1 } } }
    public var onlineReplaySubject = ReplaySubject<Bool>.create(bufferSize: 1) { didSet { if _doneInit { onlineSubjectSetCallCount += 1 } } }
    public var onlineBehaviorSubject: BehaviorSubject<Bool>! { didSet { if _doneInit { onlineSubjectSetCallCount += 1 } } }
    public var underlyingOnline: Observable<Bool>! { didSet { if _doneInit { onlineSubjectSetCallCount += 1 } } }
    public var online: Observable<Bool> {
        get {
            if onlineSubjectKind == 0 { return onlineSubject }
            else if onlineSubjectKind == 1 { return onlineBehaviorSubject }
            else if onlineSubjectKind == 2 { return onlineReplaySubject }
            else { return underlyingOnline }
        }
        set {
            if let val = newValue as? PublishSubject<Bool> { onlineSubjectKind = 0; onlineSubject = val }
            else if let val = newValue as? BehaviorSubject<Bool> { onlineSubjectKind = 1; onlineBehaviorSubject = val }
            else if let val = newValue as? ReplaySubject<Bool> { onlineSubjectKind = 2; onlineReplaySubject = val }
            else { onlineSubjectKind = 3; underlyingOnline = newValue }
        }
    }
    private var stateSubjectKind = 0
    public var stateSubjectSetCallCount = 0
    public var stateSubject = PublishSubject<State>() { didSet { if _doneInit { stateSubjectSetCallCount += 1 } } }
    public var stateReplaySubject = ReplaySubject<State>.create(bufferSize: 1) { didSet { if _doneInit { stateSubjectSetCallCount += 1 } } }
    public var stateBehaviorSubject: BehaviorSubject<State>! { didSet { if _doneInit { stateSubjectSetCallCount += 1 } } }
    public var underlyingState: Observable<State>! { didSet { if _doneInit { stateSubjectSetCallCount += 1 } } }
    public var state: Observable<State> {
        get {
            if stateSubjectKind == 0 { return stateSubject }
            else if stateSubjectKind == 1 { return stateBehaviorSubject }
            else if stateSubjectKind == 2 { return stateReplaySubject }
            else { return underlyingState }
        }
        set {
            if let val = newValue as? PublishSubject<State> { stateSubjectKind = 0; stateSubject = val }
            else if let val = newValue as? BehaviorSubject<State> { stateSubjectKind = 1; stateBehaviorSubject = val }
            else if let val = newValue as? ReplaySubject<State> { stateSubjectKind = 2; stateReplaySubject = val }
            else { stateSubjectKind = 3; underlyingState = newValue }
        }
    }
    public var isOnJobSubjectSetCallCount = 0
    var underlyingIsOnJob: Observable<Bool>? { didSet { if _doneInit { isOnJobSubjectSetCallCount += 1 } } }
    public var isOnJobSubject = BehaviorSubject<Bool>(value: false) { didSet { if _doneInit { isOnJobSubjectSetCallCount += 1 } } }
    public var isOnJob: Observable<Bool> {
        get { return underlyingIsOnJob ?? isOnJobSubject }
        set { if let val = newValue as? BehaviorSubject<Bool> { isOnJobSubject = val } else { underlyingIsOnJob = newValue } }
    }
    public var completionTasksSubjectSetCallCount = 0
    var underlyingCompletionTasks: Observable<[CompletionTask]>? { didSet { if _doneInit { completionTasksSubjectSetCallCount += 1 } } }
    public var completionTasksSubject = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]()) { didSet { if _doneInit { completionTasksSubjectSetCallCount += 1 } } }
    public var completionTasks: Observable<[CompletionTask]> {
        get { return underlyingCompletionTasks ?? completionTasksSubject }
        set { if let val = newValue as? BehaviorSubject<[CompletionTask]> { completionTasksSubject = val } else { underlyingCompletionTasks = newValue } }
    }
}

public class BaseTaskScopeListStreamMock: BaseTaskScopeListStream {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(taskScopes: Observable<[TaskScope]> = ReplaySubject<[TaskScope]>.create(bufferSize: 1)) {
        self.taskScopes = taskScopes
        _doneInit = true
    }
    public var taskScopesSubjectSetCallCount = 0
    var underlyingTaskScopes: Observable<[TaskScope]>? { didSet { if _doneInit { taskScopesSubjectSetCallCount += 1 } } }
    public var taskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { if _doneInit { taskScopesSubjectSetCallCount += 1 } } }
    public var taskScopes: Observable<[TaskScope]> {
        get { return underlyingTaskScopes ?? taskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { taskScopesSubject = val } else { underlyingTaskScopes = newValue } }
    }
}

public class WorkTaskScopeListStreamMock: WorkTaskScopeListStream {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(workTaskScopes: Observable<[TaskScope]> = ReplaySubject<[TaskScope]>.create(bufferSize: 1)) {
        self.workTaskScopes = workTaskScopes
        _doneInit = true
    }
    public var workTaskScopesSubjectSetCallCount = 0
    var underlyingWorkTaskScopes: Observable<[TaskScope]>? { didSet { if _doneInit { workTaskScopesSubjectSetCallCount += 1 } } }
    public var workTaskScopesSubject = ReplaySubject<[TaskScope]>.create(bufferSize: 1) { didSet { if _doneInit { workTaskScopesSubjectSetCallCount += 1 } } }
    public var workTaskScopes: Observable<[TaskScope]> {
        get { return underlyingWorkTaskScopes ?? workTaskScopesSubject }
        set { if let val = newValue as? ReplaySubject<[TaskScope]> { workTaskScopesSubject = val } else { underlyingWorkTaskScopes = newValue } }
    }
}

public class OnlineStreamMock: OnlineStream {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(online: Observable<Bool> = PublishSubject<Bool>()) {
        self.online = online
        _doneInit = true
    }
    private var onlineSubjectKind = 0
    public var onlineSubjectSetCallCount = 0
    public var onlineSubject = PublishSubject<Bool>() { didSet { if _doneInit { onlineSubjectSetCallCount += 1 } } }
    public var onlineReplaySubject = ReplaySubject<Bool>.create(bufferSize: 1) { didSet { if _doneInit { onlineSubjectSetCallCount += 1 } } }
    public var onlineBehaviorSubject: BehaviorSubject<Bool>! { didSet { if _doneInit { onlineSubjectSetCallCount += 1 } } }
    public var underlyingOnline: Observable<Bool>! { didSet { if _doneInit { onlineSubjectSetCallCount += 1 } } }
    public var online: Observable<Bool> {
        get {
            if onlineSubjectKind == 0 { return onlineSubject }
            else if onlineSubjectKind == 1 { return onlineBehaviorSubject }
            else if onlineSubjectKind == 2 { return onlineReplaySubject }
            else { return underlyingOnline }
        }
        set {
            if let val = newValue as? PublishSubject<Bool> { onlineSubjectKind = 0; onlineSubject = val }
            else if let val = newValue as? BehaviorSubject<Bool> { onlineSubjectKind = 1; onlineBehaviorSubject = val }
            else if let val = newValue as? ReplaySubject<Bool> { onlineSubjectKind = 2; onlineReplaySubject = val }
            else { onlineSubjectKind = 3; underlyingOnline = newValue }
        }
    }
}

public class StateStreamMock: StateStream {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(state: Observable<State> = PublishSubject<State>()) {
        self.state = state
        _doneInit = true
    }
    private var stateSubjectKind = 0
    public var stateSubjectSetCallCount = 0
    public var stateSubject = PublishSubject<State>() { didSet { if _doneInit { stateSubjectSetCallCount += 1 } } }
    public var stateReplaySubject = ReplaySubject<State>.create(bufferSize: 1) { didSet { if _doneInit { stateSubjectSetCallCount += 1 } } }
    public var stateBehaviorSubject: BehaviorSubject<State>! { didSet { if _doneInit { stateSubjectSetCallCount += 1 } } }
    public var underlyingState: Observable<State>! { didSet { if _doneInit { stateSubjectSetCallCount += 1 } } }
    public var state: Observable<State> {
        get {
            if stateSubjectKind == 0 { return stateSubject }
            else if stateSubjectKind == 1 { return stateBehaviorSubject }
            else if stateSubjectKind == 2 { return stateReplaySubject }
            else { return underlyingState }
        }
        set {
            if let val = newValue as? PublishSubject<State> { stateSubjectKind = 0; stateSubject = val }
            else if let val = newValue as? BehaviorSubject<State> { stateSubjectKind = 1; stateBehaviorSubject = val }
            else if let val = newValue as? ReplaySubject<State> { stateSubjectKind = 2; stateReplaySubject = val }
            else { stateSubjectKind = 3; underlyingState = newValue }
        }
    }
}

public class WorkStateStreamMock: WorkStateStream {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(isOnJob: Observable<Bool> = BehaviorSubject<Bool>(value: false)) {
        self.isOnJob = isOnJob
        _doneInit = true
    }
    public var isOnJobSubjectSetCallCount = 0
    var underlyingIsOnJob: Observable<Bool>? { didSet { if _doneInit { isOnJobSubjectSetCallCount += 1 } } }
    public var isOnJobSubject = BehaviorSubject<Bool>(value: false) { didSet { if _doneInit { isOnJobSubjectSetCallCount += 1 } } }
    public var isOnJob: Observable<Bool> {
        get { return underlyingIsOnJob ?? isOnJobSubject }
        set { if let val = newValue as? BehaviorSubject<Bool> { isOnJobSubject = val } else { underlyingIsOnJob = newValue } }
    }
}

public class CompletionTasksStreamMock: CompletionTasksStream {
    
    private var _doneInit = false
    
    public init() { _doneInit = true }
    public init(completionTasks: Observable<[CompletionTask]> = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]())) {
        self.completionTasks = completionTasks
        _doneInit = true
    }
    public var completionTasksSubjectSetCallCount = 0
    var underlyingCompletionTasks: Observable<[CompletionTask]>? { didSet { if _doneInit { completionTasksSubjectSetCallCount += 1 } } }
    public var completionTasksSubject = BehaviorSubject<[CompletionTask]>(value: [CompletionTask]()) { didSet { if _doneInit { completionTasksSubjectSetCallCount += 1 } } }
    public var completionTasks: Observable<[CompletionTask]> {
        get { return underlyingCompletionTasks ?? completionTasksSubject }
        set { if let val = newValue as? BehaviorSubject<[CompletionTask]> { completionTasksSubject = val } else { underlyingCompletionTasks = newValue } }
    }
}
"""

