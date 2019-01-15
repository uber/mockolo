

# SwiftMockGen

SwiftMockGen is a lightweight framework for creating mocks in Swift.  It uses a concurrent swift file 
scanner and `SourceKittenFramework` for parsing and a custom template renderer for generating a mock output.  


## Building and developing

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

## Running the program

SwiftMockGen produces a commandline executable. To run it, pass in the source file directory of a module, destination directory for the mock output, and a list of any mock files that are needed for the module. 

```swift
swift-mockgen /Users/myName/myApp/src/myModule /Users/myName/myApp/dst/myModule /Users/myName/myApp/src/moduleX/XMocks.swift /Users/myName/myApp/src/moduleY/YMocks.swift /Users/myName/myApp/src/moduleZ/ZMocks.swift 
```
The above will run the program on the source files in `/Users/myName/myApp/src/myModule` using the input mock files `XMocks.swift`, `YMocks.swift`, and `ZMocks.swift`, and generates the final mock output file at `/Users/myName/myApp/dst/myModule`.



