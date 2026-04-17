import Testing
@testable import MLNetworkLayer

struct PackageMetadataTests {
    @Test
    func versionNumber() {
        #expect(MLNetworkLayer.VERSION.rawValue == "3.0.0")
    }
}
