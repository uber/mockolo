import Foundation

class NameOverrideTests: MockoloTestCase {
    func testNameOverride() {
        verify(srcContent: nameOverride, dstContent: nameOverrideMock)
    }
    
    let baseCustomizations: [String?] = [nil, "BaseProtocolMock", "BaseMock", "FakeBase"]
    let derivedCustomizations: [String?] = [nil, "DerivedProtocolMock", "DerivedMock", "FakeDerived"]
    
    func testBaseFixtures() {
        for baseCustomization in baseCustomizations {
            verify(srcContent: baseProtocol(customName: baseCustomization), dstContent: baseMock(customName: baseCustomization))
        }
    }
    
    func testDerivedFixtures() {
        for baseCustomization in baseCustomizations {
            let baseImplementation = baseMock(customName: baseCustomization)
            for derivedCustomization in derivedCustomizations {
                verify(
                    srcContent: derivedProtocol(customName: derivedCustomization),
                    mockContent: baseImplementation,
                    dstContent: derivedMock(customName: derivedCustomization)
                )
            }
        }
    }
    
}
