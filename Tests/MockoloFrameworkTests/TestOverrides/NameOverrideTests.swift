import Foundation

class NameOverrideTests: MockoloTestCase {
    func testNameOverride() {
        verify(srcContent: nameOverride, dstContent: nameOverrideMock)
    }
    
    // MARK: - Verify `BaseProtocol` Fixtures
    
    // we have the same protocol (`BaseProtocol`) mocked 4 different ways:
    //
    // - no name override
    // - name override to default `BaseProtocolMock`
    // - name override to `BaseMock`
    // - name override to `FakeBase`
    //
    // These first four tests verify our fixtures are valid as mockolo output.
    func testBaseProtocolNoCustomizationFixtures() {
        verify(srcContent: baseProtocol_NoCustomization, dstContent: baseProtocolMock_Named_BaseProtocolMock)
    }

    func testBaseProtocolNameOverrideToDefaultFixtures() {
        verify(srcContent: baseProtocol_MockedAs_BaseProtocolMock, dstContent: baseProtocolMock_Named_BaseProtocolMock)
    }

    func testBaseProtocolNameOverrideToBaseMockFixtures() {
        verify(srcContent: baseProtocol_MockedAs_BaseMock, dstContent: baseProtocolMock_Named_BaseMock)
    }

    func testBaseProtocolNameOverrideToFakeBaseFixtures() {
        verify(srcContent: baseProtocol_MockedAs_FakeBase, dstContent: baseProtocolMock_Named_FakeBase)
    }

    // MARK: - Verify `DerivedProtocol` Mocks
    
    // We have three distinct names for the `BaseProtocol`'s mocks:
    //
    // - `BaseProtocolMock`
    // - `BaseMock`
    // - `FakeBase`
    //
    // We also have four mocking declarations for `DerivedProtocol`:
    //
    // - no name override
    // - name override to default `DerivedProtocolMock`
    // - name override to `DerivedMock`
    // - name override to `FakeDerived`
    //
    // In the following four tests, we verify that all combinations produce the expected results.
    // In other words, we verify that mockolo can figure out that protocol inheritance
    // `DerivedProtocol: BaseProtocol` matches up with the generated base mock regardless
    // of how `BaseProtocol`'s mock was named.
    
    func testDerivedProtocolNoCustomization() {
        verify(
            srcContent: derivedProtocol_NoCustomization,
            mockContent: baseProtocolMock_Named_BaseProtocolMock,
            dstContent: derivedMock_Named_DerivedProtocolMock
        )
        verify(
            srcContent: derivedProtocol_NoCustomization,
            mockContent: baseProtocolMock_Named_BaseMock,
            dstContent: derivedMock_Named_DerivedProtocolMock
        )
        verify(
            srcContent: derivedProtocol_NoCustomization,
            mockContent: baseProtocolMock_Named_FakeBase,
            dstContent: derivedMock_Named_DerivedProtocolMock
        )
    }

    func testDerivedProtocolNameOverrideToDefault() {
        verify(
            srcContent: derivedProtocol_MockedAs_DerivedProtocolMock,
            mockContent: baseProtocolMock_Named_BaseProtocolMock,
            dstContent: derivedMock_Named_DerivedProtocolMock
        )
        verify(
            srcContent: derivedProtocol_MockedAs_DerivedProtocolMock,
            mockContent: baseProtocolMock_Named_BaseMock,
            dstContent: derivedMock_Named_DerivedProtocolMock
        )
        verify(
            srcContent: derivedProtocol_MockedAs_DerivedProtocolMock,
            mockContent: baseProtocolMock_Named_FakeBase,
            dstContent: derivedMock_Named_DerivedProtocolMock
        )
    }

    func testDerivedProtocolNameOverrideToDerivedMock() {
        verify(
            srcContent: derivedProtocol_MockedAs_DerivedMock,
            mockContent: baseProtocolMock_Named_BaseProtocolMock,
            dstContent: derivedMock_Named_DerivedMock
        )
        verify(
            srcContent: derivedProtocol_MockedAs_DerivedMock,
            mockContent: baseProtocolMock_Named_BaseMock,
            dstContent: derivedMock_Named_DerivedMock
        )
        verify(
            srcContent: derivedProtocol_MockedAs_DerivedMock,
            mockContent: baseProtocolMock_Named_FakeBase,
            dstContent: derivedMock_Named_DerivedMock
        )
    }

    func testDerivedProtocolNameOverrideToFakeDerivedFixtures() {
        verify(
            srcContent: derivedProtocol_MockedAs_FakeDerived,
            mockContent: baseProtocolMock_Named_BaseProtocolMock,
            dstContent: derivedMock_Named_FakeDerived
        )
        verify(
            srcContent: derivedProtocol_MockedAs_FakeDerived,
            mockContent: baseProtocolMock_Named_BaseMock,
            dstContent: derivedMock_Named_FakeDerived
        )
        verify(
            srcContent: derivedProtocol_MockedAs_FakeDerived,
            mockContent: baseProtocolMock_Named_FakeBase,
            dstContent: derivedMock_Named_FakeDerived
        )
    }

}
