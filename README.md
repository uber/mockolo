

# SwiftMockGen

`SwiftMockGen` is a lightweight commandline tool that uses the `SwiftMockGenCore` framework for creating mocks in Swift.  It uses a concurrent swift file scanner and `SourceKittenFramework` for parsing, and a custom template renderer for generating a mock output.  


## Build

First resolve the dependencies:

```
$ swift package resolve
```

Then build from the command-line:

```
$ swift build
```

Or create an Xcode project and build using the IDE:

```
$ swift package generate-xcodeproj 
```

## Run

SwiftMockGen produces a commandline executable. To run it, pass in a list of the source file paths of a build target, the ouptut filepath for the mock output, any file name suffixes that need to be excluded if any, and a list of any mock files that are needed to generate mocks for the current build target. 

For example,

```swift

.build/release/swiftmockgen generate --outputfile apps/result/Mocks.swift 
--sourcefiles apps/src/File1.swift, apps/src/File2.swift 
--mockfiles "apps/libFoo/FooMocks.swift", "apps/libBar/BarMocks.swift"
--exclude-suffixes "Mocks", "Tests", "Models", "Services"
```

The above will run the program on the source files passed in, excluding any files with suffixes "Tests", "Mocks", etc, use input mock files `FooMocks.swift` and `BarMocks.swift` to resolve inheritance if needed, and generate the mock output to the `Mocks.swift` file.



