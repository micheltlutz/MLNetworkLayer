import Testing
@testable import MLNetworkLayer

struct ProviderEncodingTests {
    @Test
    func networkProviderTypes() {
        let networkProvider = NetworkProviderType.network
        let stubProvider = NetworkProviderType.stub
        #expect(networkProvider != stubProvider)
    }

    @Test
    func parameterEncodingTypes() {
        let bodyEncoding = ParameterEncoding.body
        let urlEncoding = ParameterEncoding.url
        #expect(bodyEncoding != urlEncoding)
    }
}
