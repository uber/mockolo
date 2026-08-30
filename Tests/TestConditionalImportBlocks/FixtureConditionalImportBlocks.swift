enum FixtureConditionalImportBlocks {

    /// Protocol inside a #if block that contains non-import declarations
    static let protocolInIfBlock =
        """
        #if os(iOS)
        /// @mockable
        public protocol PlatformProtocol {
            func platformFunction()
        }
        #endif
        """

    /// Expected mock for protocol inside #if block — mock is wrapped in the same #if
    static let protocolInIfBlockMock =
        """
        #if os(iOS)
        public class PlatformProtocolMock: PlatformProtocol {
            public init() { }


            public private(set) var platformFunctionCallCount = 0
            public var platformFunctionHandler: (() -> ())?
            public func platformFunction() {
                platformFunctionCallCount += 1
                if let platformFunctionHandler = platformFunctionHandler {
                    platformFunctionHandler()
                }
            }
        }
        #endif
        """

    /// Protocol inside a #if block containing only imports (should be treated as conditional import)
    static let conditionalImportBlock =
        """
        #if canImport(Foundation)
        import Foundation
        #endif

        /// @mockable
        public protocol ServiceProtocol {
            func execute()
        }
        """

    /// Expected output with conditional import preserved and protocol mocked
    static let conditionalImportBlockMock =
        """
        #if canImport(Foundation)
        import Foundation
        #endif


        public class ServiceProtocolMock: ServiceProtocol {
            public init() { }


            public private(set) var executeCallCount = 0
            public var executeHandler: (() -> ())?
            public func execute() {
                executeCallCount += 1
                if let executeHandler = executeHandler {
                    executeHandler()
                }
            }
        }
        """

    /// Multiple protocols in nested #if blocks with mixed content
    static let nestedIfBlocks =
        """
        #if os(iOS)
        /// @mockable
        public protocol iOSProtocol {
            func iosMethod()
        }
        #elseif os(macOS)
        /// @mockable
        public protocol macOSProtocol {
            func macosMethod()
        }
        #endif
        """

    /// Expected mocks for both protocols, preserving #if/#elseif structure
    static let nestedIfBlocksMock =
        """
        #if os(iOS)
        public class iOSProtocolMock: iOSProtocol {
            public init() { }


            public private(set) var iosMethodCallCount = 0
            public var iosMethodHandler: (() -> ())?
            public func iosMethod() {
                iosMethodCallCount += 1
                if let iosMethodHandler = iosMethodHandler {
                    iosMethodHandler()
                }
            }
        }
        #elseif os(macOS)
        public class macOSProtocolMock: macOSProtocol {
            public init() { }


            public private(set) var macosMethodCallCount = 0
            public var macosMethodHandler: (() -> ())?
            public func macosMethod() {
                macosMethodCallCount += 1
                if let macosMethodHandler = macosMethodHandler {
                    macosMethodHandler()
                }
            }
        }
        #endif
        """

    /// #if block with imports and a protocol (should visit children and discover protocol)
    static let ifBlockWithImportsAndProtocol =
        """
        #if DEBUG
        import XCTest
        /// @mockable
        public protocol DebugProtocol {
            func debugFunction()
        }
        #endif
        """

    /// Import is captured as conditional import, mock is wrapped in #if
    static let ifBlockWithImportsAndProtocolMock =
        """
        #if DEBUG
        import XCTest
        #endif


        #if DEBUG
        public class DebugProtocolMock: DebugProtocol {
            public init() { }


            public private(set) var debugFunctionCallCount = 0
            public var debugFunctionHandler: (() -> ())?
            public func debugFunction() {
                debugFunctionCallCount += 1
                if let debugFunctionHandler = debugFunctionHandler {
                    debugFunctionHandler()
                }
            }
        }
        #endif
        """

    /// Nested #if blocks where inner only contains imports
    static let mixedNestedBlocks =
        """
        #if os(iOS)
        #if DEBUG
        import XCTest
        #endif
        /// @mockable
        public protocol MixedProtocol {
            func mixedMethod()
        }
        #endif
        """

    /// Nested import block preserved, mock wrapped in outer #if
    static let mixedNestedBlocksMock =
        """
        #if os(iOS)
        #if DEBUG
        import XCTest
        #endif
        #endif


        #if os(iOS)
        public class MixedProtocolMock: MixedProtocol {
            public init() { }


            public private(set) var mixedMethodCallCount = 0
            public var mixedMethodHandler: (() -> ())?
            public func mixedMethod() {
                mixedMethodCallCount += 1
                if let mixedMethodHandler = mixedMethodHandler {
                    mixedMethodHandler()
                }
            }
        }
        #endif
        """
}
