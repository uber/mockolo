enum FixtureACLImport {

    /// Input that contains various import access levels
    static let primary =
        """
        public import A
        package import B
        internal import C
        fileprivate import D
        private import E
        import F

        \(FixtureHelpers.someProtocol)
        """
    
    /// Output when source is just `primary`
    static let primaryMock =
        """
        public import A
        package import B
        internal import C
        fileprivate import D
        private import E
        import F


        \(FixtureHelpers.someProtocolMock)
        """

    /// Output when source is just `primary` and `testableImports = [B,C,D,E,F]`
    /// Testable imports trump access levels (they can't both be used).
    static let primaryTestableMock =
        """
        public import A
        @testable import B
        @testable import C
        @testable import D
        @testable import E
        @testable import F


        \(FixtureHelpers.someProtocolMock)
        """
    
    /// Input that contains various import access levels, clashing with those from `primary`
    static let secondary =
        """
        package import A
        internal import B
        fileprivate import C
        private import D
        public import E
        internal import F

        \(FixtureHelpers.someProtocol2)
        """
    
    /// Output when source includes both `primary` and `secondary`.
    /// Access levels for each import are promoted to the highest one seen in input.
    static let primarySecondaryMock =
        """
        public import A
        package import B
        internal import C
        fileprivate import D
        public import E
        internal import F


        \(FixtureHelpers.someProtocolMock)
        
        \(FixtureHelpers.someProtocol2Mock)
        """

    /// Input with attributes on imports, including attributes on their own line.
    static let attributed =
        """
        @_spi(X) import A
        @preconcurrency import B
        @_implementationOnly import C
        @testable import D
        @_spi(Y) public import E
        @preconcurrency
        import F
        @diagnose(UnusedImportAccess, as: ignored)
        import G
        #if canImport(H)
        @preconcurrency
        package import H
        #endif

        \(FixtureHelpers.someProtocol)
        """

    /// Attributes other than `@testable` are dropped; access levels are kept.
    static let attributedMock =
        """
        import A
        import B
        import C
        @testable import D
        public import E
        import F
        import G
        #if canImport(H)
        package import H
        #endif


        \(FixtureHelpers.someProtocolMock)
        """

    /// Import header emitted by swift-openapi-generator 1.14+.
    static let openAPIGeneratorHeader =
        """
        #if compiler(>=6.4)
        @diagnose(UnusedImportAccess, as: ignored)
        #endif
        @_spi(Generated) public import OpenAPIRuntime
        #if os(Linux)
        @preconcurrency public import struct Foundation.URL
        #else
        public import struct Foundation.URL
        #endif

        \(FixtureHelpers.someProtocol)
        """

    static let openAPIGeneratorHeaderMock =
        """
        public import OpenAPIRuntime
        #if os(Linux)
        public import struct Foundation.URL
        #else
        public import struct Foundation.URL
        #endif


        \(FixtureHelpers.someProtocolMock)
        """
}
