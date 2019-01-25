

# SwiftMockGen

SwiftMockGen is a lightweight framework for creating mocks in Swift.  It uses a concurrent swift file 
scanner and `SourceKittenFramework` for parsing and a custom template renderer for generating a mock output.  


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

SwiftMockGen produces a commandline executable. To run it, pass in the source file directory of a module, destination filepath for the mock output, any suffixes that need to be excluded if any, and a list of any mock files that are needed for the module. 

```swift
[path to SwiftMockGen executable] mockgen --source-files-dir [path to source files dir] --exclude-suffixes [suffix string1] [suffix string2] --dependent-filepaths [path to filepath1] [path to filepath2] [path to filepath3] --output-filepath [path to output filepath]
```

For example,  
```swift
./SwiftMockGen mockgen --source-files-dir /Users/dev/app/src/moduleA 
                       --exclude-suffixes "Tests" "Mocks"
                       --dependent-filepaths /Users/dev/app/src/moduleB/file1.swift /Users/dev/app/src/moduleC/file2.swift
                       --output-filepath /Users/dev/app/src/moduleA/ResultMocks.swift
```
The above will run the program on the source files in `/Users/dev/app/src/moduleA` excluding any files with suffixes "Tests" or "Mocks", by taking dependent files `file1.swift` and `file2.swift`, and generate the resulting mock output at the `ResultMocks.swift` file.



