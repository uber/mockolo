# ![](Images/logo.png)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/2964/badge)](https://bestpractices.coreinfrastructure.org/projects/2964)
[![Build Status](https://github.com/uber/mockolo/actions/workflows/builds.yml/badge.svg?branch=master)](https://github.com/uber/mockolo/actions/workflows/builds.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![FOSSA Status](https://app.fossa.com/api/projects/custom%2B4458%2Fgithub.com%2Fuber%2Fmockolo.svg?type=shield)](https://app.fossa.com/projects/custom%2B4458%2Fgithub.com%2Fuber%2Fmockolo?ref=badge_shield)

# Welcome to Mockolo

**Mockolo** is an efficient mock generator for Swift. Swift doesn't provide mocking support, and Mockolo provides a fast and easy way to autogenerate mock objects that can be tested in your code. One of the main objectives of Mockolo is fast performance.  Unlike other frameworks, Mockolo provides highly performant and scalable generation of mocks via a lightweight commandline tool, so it can  run as part of a linter or a build if one chooses to do so. Try Mockolo and enhance your project's test coverage in an effective, performant way.


## Motivation
One of the main objectives of this project is high performance.  There aren't many 3rd party tools that perform fast on a large codebase containing, for example, over 2M LoC or over 10K protocols.  They take several hours and even with caching enabled take several minutes.  Mockolo was built to make highly performant generation of mocks possible (in the magnitude of seconds) on such large codebase. It uses a minimal set of frameworks necessary (mentioned in the Used libraries section) to keep the code lean and efficient.

Another objective is to enable flexibility in using or overriding types if needed. This allows use of some of the features that require deeper analysis such as protocols with associated types to be simpler, more straightforward, and less fragile.


## Disclaimer
This project may contain unstable APIs which may not be ready for general use. Support and/or new releases may be limited.


## System Requirements

* Swift 5.4 or later
* Xcode 12.5 or later
* MacOS 11.0 or later
* Support is included for the Swift Package Manager


## Build / Install

Option 1: By [Mint](https://github.com/yonaskolb/Mint)

```
$ mint install uber/mockolo
$ mint run uber/mockolo mockolo -h // see commandline input options below 
```

Option 2: [Homebrew](https://brew.sh/)

```
$ brew install mockolo
```

Option 3: Use the binary  

  Go to the Release tab and download/install the binary directly. 


Option 4: Clone and build/run 

```
$ git clone https://github.com/uber/mockolo.git
$ cd mockolo
$ swift build -c release
$ .build/release/mockolo -h  // see commandline input options below 
```

To call mockolo from any location, copy the executable into a directory that is part of your `PATH` environment variable.


To check out a specific version, 

```
$ git tag -l
$ git checkout [tag]
```

To use Xcode to build and run, 

```
$ swift package generate-xcodeproj
```

## Run

`Mockolo` is a commandline executable. To run it, pass in a list of the source file directories or file paths of a build target, and the destination filepath for the mock output. To see other arguments to the commandline, run `mockolo --help`.

```
./mockolo -s myDir -d ./OutputMocks.swift -x Images Strings
```

This parses all the source files in `myDir` directory, excluding any files ending with `Images` or `Strings` in the file name (e.g. MyImages.swift), and generates mocks to a file at `OutputMocks.swift` in the current directory.

Use --help to see the complete argument options.

```
./mockolo -h  // or --help

OVERVIEW: Mockolo: Swift mock generator.

USAGE: mockolo <options>

OPTIONS:
  --allow-set-callcount     If set, generated *CallCount vars will be allowed to set manually. 
  --annotation, -a          A custom annotation string used to indicate if a type should be mocked (default = @mockable).
  --concurrency-limit, -j   Maximum number of threads to execute concurrently (default = number of cores on the running machine).
  --custom-imports, -c      If set, custom module imports will be added to the final import statement list.
  --destination, -d         Output file path containing the generated Swift mock classes. If no value is given, the program will exit.
  --enable-args-history     Whether to enable args history for all functions (default = false). To enable history per function, use the 'history' keyword in the annotation argument. 
  --exclude-imports         If set, listed modules will be excluded from the import statements in the mock output.
  --exclude-suffixes, -x    List of filename suffix(es) without the file extensions to exclude from parsing (separated by a comma or a space).
  --filelist, -f            Path to a file containing a list of source file paths (delimited by a new line). If the --sourcedirs value exists, this will be ignored. 
  --header                  A custom header documentation to be added to the beginning of a generated mock file.
  --logging-level, -l       The logging level to use. Default is set to 0 (info only). Set 1 for verbose, 2 for warning, and 3 for error.
  --macro, -m               If set, #if [macro] / #endif will be added to the generated mock file content to guard compilation.
  --mock-all                If set, it will mock all types (protocols and classes) with a mock annotation (default is set to false and only mocks protocols with a mock annotation).
  --mock-filelist           Path to a file containing a list of dependent files (separated by a new line) of modules this target depends on.
  --mock-final              If set, generated mock classes will have the 'final' attributes (default is set to false).
  --mockfiles, -mocks       List of mock files (separated by a comma or a space) from modules this target depends on. If the --mock-filelist value exists, this will be ignored.
  --sourcedirs, -s          Paths to the directories containing source files to generate mocks for. If the --filelist or --sourcefiles values exist, they will be ignored. 
  --sourcefiles, -srcs      List of source files (separated by a comma or a space) to generate mocks for. If the --sourcedirs or --filelist value exists, this will be ignored. 
  --testable-imports, -i    If set, @testable import statments will be added for each module name in this list.
  --use-mock-observable     If set, a property wrapper will be used to mock RxSwift Observable variables (default is set to false).
  --use-template-func       If set, a common template function will be called from all functions in mock classes (default is set to false).
  --help                    Display available options
  ```


## Add MockoloFramework to your project

Option 1: SPM 
```swift

dependencies: [
    .package(url: "https://github.com/uber/mockolo.git", from: "1.1.2"),
],
targets: [
    .target(name: "MyTarget", dependencies: ["MockoloFramework"]),
]

```
Option 2: Cocoapods 
```
target 'MyTarget' do
  platform :osx, '10.14'
  pod 'MockoloFramework', '~>1.1.2' 
end
```


## Distribution 

The `install-script.sh` will build and package up the `mockolo` binary and other necessary resources in the same bundle. 

```
$ ./install-script.sh -h  // see input options 
$ ./install-script.sh -s [source dir] -t mockolo -d [destination dir] -o [output filename].tar.gz
```

This will create a tarball for distribution, which contains the `mockolo` executable along with a necessary SwiftSyntax parser dylib (lib_InternalSwiftSyntaxParser.dylib). This allows running `mockolo` without depending on where the dylib lives. 



## How to use

For example, Foo.swift contains:

```swift
/// @mockable
public protocol Foo {
    var num: Int { get set }
    func bar(arg: Float) -> String
}
```

Running ```./mockolo -srcs Foo.swift -d ./OutputMocks.swift ``` will output:

```swift
public class FooMock: Foo {
    init() {}
    init(num: Int = 0) {
        self.num = num
    }

    var numSetCallCount = 0
    var underlyingNum: Int = 0
    var num: Int {
        get {
            return underlyingNum
        }
        set {
            underlyingNum = newValue
            numSetCallCount += 1
        }
    }

    var barCallCount = 0
    var barHandler: ((Float) -> (String))?
    func bar(arg: Float) -> String {
        barCallCount += 1
        if let barHandler = barHandler {
            return barHandler(arg)
        }
        return ""
    }
}
```

The above mock can now be used in a test as follows:

```swift
func testMock() {
    let mock = FooMock(num: 5)
    XCTAssertEqual(mock.numSetCallCount, 1)
    mock.barHandler = { arg in
        return String(arg)
    }
    XCTAssertEqual(mock.barCallCount, 1)
}
```

## Arguments

A list of override arguments can be passed in (delimited by a semicolon) to the annotation to set var types, typealiases, module names, etc. 


### Module

```swift
/// @mockable(module: prefix = Bar)
public protocol Foo {
    ...
}
```

This will generate: 

```swift
public class FooMock: Bar.Foo {
    ...
}
```

### Typealias

```swift
/// @mockable(typealias: T = AnyObject; U = StringProtocol)
public protocol Foo {
    associatedtype T
    associatedtype U: Collection where U.Element == T 
    associatedtype W 
    ...
}
```

This will generate the following mock output: 

```swift
public class FooMock: Foo {
    typealias T = AnyObject // overriden
    typealias U = StringProtocol // overriden
    typealias W = Any // default placeholder type for typealias
    ...
}
```


### RxSwift

For a var type such as an RxSwift observable:

```swift
/// @mockable(rx: intStream = ReplaySubject; doubleStream = BehaviorSubject)
public protocol Foo {
    var intStream: Observable<Int> { get }
    var doubleStream: Observable<Double> { get }
}
```

This will generate: 

```swift
public class FooMock: Foo {
    var intStreamSubject = ReplaySubject<Int>.create(bufferSize: 1)
    var intStream: Observable<Int> { /* use intStreamSubject */ }
    var doubleStreamSubject = BehaviorSubject<Int>(value: 0)
    var doubleStream: Observable<Int> { /* use doubleStreamSubject */ }
}
```

### Function Argument History

To capture function arguments history:

```swift
/// @mockable(history: fooFunc = true)
public protocol Foo {
    func fooFunc(val: Int)
    func barFunc(_ val: (a: String, Float))
    func bazFunc(val1: Int, val2: String)
}
```

This will generate: 

```swift
public class FooMock: Foo {
    var fooFuncCallCount = 0
    var fooFuncArgValues = [Int]() // arguments captor
    var fooFuncHandler: ((Int) -> ())?
    func fooFunc(val: Int) {
        fooFuncCallCount += 1
        fooFuncArgValues.append(val)   // capture arguments

        if fooFuncHandler = fooFuncHandler {
            fooFuncHandler(val)
        }
    }

    ...
    var barFuncArgValues = [(a: String, Float)]() // tuple is also supported.
    ...

    ...
    var bazFuncArgValues = [(Int, String)]()
    ...
}
```

and also, enable the arguments captor for all functions if you passed `--enable-args-history` arg to `mockolo` command.
> NOTE: The arguments captor only supports singular types (e.g. variable, tuple). The closure variable is not supported.

### Combine's AnyPublisher

To generate mocks for Combine's AnyPublisher:

```swift
/// @mockable(combine: fooPublisher = PassthroughSubject; barPublisher = CurrentValueSubject)
public protocol Foo {
    var fooPublisher: AnyPublisher<String, Never> { get }
    var barPublisher: AnyPublisher<Int, CustomError> { get }
}
```

This will generate:

```swift
public class FooMock: Foo {
    public init() { }

    public var fooPublisher: AnyPublisher<String, Never> { return self.fooPublisherSubject.eraseToAnyPublisher() }
    public private(set) var fooPublisherSubject = PassthroughSubject<String, Never>()

    public var barPublisher: AnyPublisher<Int, CustomError> { return self.barPublisherSubject.eraseToAnyPublisher() }
    public private(set) var barPublisherSubject = CurrentValueSubject<Int, CustomError>(0)
}
```

You can also connect an AnyPublisher to a property within the protocol.

For example:
```swift
/// @mockable(combine: fooPublisher = @Published foo)
public protocol Foo {
    var foo: String { get }
    var fooPublisher: AnyPublisher<String, Never> { get }
}
```

This will generate:
```swift
public class FooMock: Foo {
    public init() { }
    public init(foo: String = "") {
        self.foo = foo
    }

    public private(set) var fooSetCallCount = 0
    @Published public var foo: String = "" { didSet { fooSetCallCount += 1 } }

    public var fooPublisher: AnyPublisher<String, Never> { return self.$foo.setFailureType(to: Never.self).eraseToAnyPublisher() }
}
```

## Used libraries

[SwiftSyntax](https://github.com/apple/swift-syntax) | 


## How to contribute to Mockolo
See [CONTRIBUTING](CONTRIBUTING.md) for more info.


## Report any issues

If you run into any problems, please file a git issue. Please include:

* The OS version (e.g. macOS 10.14.6)
* The Swift version installed on your machine (from `swift --version`)
* The Xcode version
* The specific release version of this source code (you can use `git tag` to get a list of all the release versions or `git log` to get a specific commit sha)
* Any local changes on your machine



## License

Mockolo is licensed under Apache License 2.0. See [LICENSE](LICENSE.txt) for more information.

    Copyright (C) 2017 Uber Technologies

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

