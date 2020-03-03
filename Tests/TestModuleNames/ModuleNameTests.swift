import Foundation

class ModuleNameTests: MockoloTestCase {
    
    func testModuleOverride() {
        verify(srcContent: moduleOverride,
               dstContent: moduleOverrideMock)
    }
}
