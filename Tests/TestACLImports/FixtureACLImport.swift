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

    /// Output when source is just `primary` and `testableImports = [B,C,D]`
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
}
