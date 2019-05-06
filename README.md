

# Mockolo

`Mockolo` is a lightweight commandline tool that uses the `MockoloFramework` framework for creating mocks in Swift.  It uses a concurrent swift file scanner and `SourceKittenFramework` for parsing, and a custom template renderer for generating a mock output.  


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

`Mockolo` produces a commandline executable. To run it, pass in a list of the source dirs or file paths of a build target and the ouptut filepath for the resulting mock output. Optional input parameters include a custom annotation string, file name suffixes that need to be excluded, a list of files containing dependent mocks if needed by the current build target, etc.

For example,

```swift

.build/release/mockolo -srcdirs /User/foo/srcs -out /User/foo/output/Result.swift -exclude "Resources"
```

The above will run the program on the source directories passed in, excluding any swift files with suffixes "Resources", and generate the mock output to the `Result.swift` file.



