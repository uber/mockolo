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

* Swift 5.1 or later
* Xcode 11.2 or later
* MacOS 10.14.6 or later
* Support is included for the Swift Package Manager


## Build / Install

First, clone the project.

```
$ git clone https://github.com/uber/mockolo.git
$ cd mockolo
```

Optionally, see a list of released versions of `Mockolo`, and check one out by running the following.

```
$ git tag -l
$ git checkout [tag]
```

Option 1: Run the following to make a release build.

```
$ swift build -c release
```

This will create a binary called `mockolo` in the `.build/release` directory.
To install, just copy this executable into a directory that is part of your `PATH` environment variable.

Option 2: Run the install-script.sh (-h to see options)

```
$ ./install-script.sh -s [source dir] -t mockolo -d [destination dir] -o [output filename]
```

This will create a tarball for distribution, which contains the mockolo executable along with a necessary SwiftSyntax parser dylib (lib_InternalSwiftSyntaxParser.dylib). This allows running mockolo without depending on where the dylib lives. 


To use Xcode, run the following.

```
$ swift package generate-xcodeproj
```


## Add MockoloFramework to your project

```swift

dependencies: [
    .package(url: "https://github.com/uber/mockolo.git", from: "1.1.0"),
],
targets: [
    .target(name: "MyTarget", dependencies: ["MockoloFramework"]),
]

```


## Run

`Mockolo` is a commandline executable. To run it, pass in a list of the source file directories or file paths of a build target, and the destination filepath for the mock output. To see other arguments to the commandline, run `mockolo --help`.

```
.build/release/mockolo -s MyDir -d ./MockResults.swift -x Images Strings
```

This parses all the source files in `MyDir` directory, excluding any files ending with `Images` or `Strings` in the file name (e.g. MyImages.swift), and generates mocks to a file at `./MockResults.swift`.

Use --help to see the complete argument options.

```
.build/release/mockolo --help

OVERVIEW: Mockolo: Swift mock generator.

USAGE: mockolo <options>

OPTIONS:
  --destination, -d       Output file path containing the generated Swift mock classes. If no value is given, the program will exit.
  --sourcedirs, -s        Paths to the directories containing source files to generate mocks for. If the --filelist or --sourcefiles values exist, they will be ignored.
  --sourcefiles, -srcs    List of source files (separated by a comma or a space) to generate mocks for. If the --sourcedirs or --filelist value exists, this will be ignored.
  --filelist, -f          Path to a file containing a list of source file paths (delimited by a new line). If the --sourcedirs value exists, this will be ignored.
  --exclude-suffixes, -x  List of filename suffix(es) without the file extensions to exclude from parsing (separated by a comma or a space).
  --depfilelist, -deplist Path to a file containing a list of dependent files (separated by a new line) from modules this target depends on. 
  --mockfiles, -mocks     List of mock files (separated by a comma or a space) from modules this target depends on.
  --annotation, -a        A custom annotation string used to indicate if a type should be mocked (default = @mockable).
  --header, -h            A custom header documentation to be added to the beginning of a generated mock file.
  --macro, -m             If set, #if [macro] / #endif will be added to the generated mock file content to guard compilation.
  --concurrency-limit, -j Maximum number of threads to execute concurrently (default = number of cores on the running machine).
  --logging-level, -v     The logging level to use. Default is set to 0 (info only). Set 1 for verbose, 2 for warning, and 3 for error.
  --help                  Displays available options.
  ```


## How to use

For example, Foo.swift contains:

```swift
/// @mockable
public protocol Foo {
    var num: Int { get set }
    func bar(arg: Float) -> String
}
```

Running the commandline ```.build/release/mockolo -srcs Foo.swift -d ./MockResults.swift ``` will produce:

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

An override argument, e.g. for a typealias, can be passed into the annotation (default or custom) delimited by a semi-colon. 

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


## TODO
It currently supports protocol mocking.  Class mocking will be added in the future.


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
