import Foundation
import Testing
@testable import MLNetworkLayer

struct NetworkManagerTests {
    /// Várias tarefas paralelas partilham o mesmo `NetworkManager` e alternam estratégias de data no decoder.
    @Test(.tags(.networking))
    func concurrentDecodingWithSharedNetworkManager() async throws {
        let token = UUID().uuidString
        let json = #"{"id":1,"name":"Concurrent","email":"c@example.com"}"#
        let responseURL = try #require(URL(string: "https://api.test/users"))

        TestMockURLHandlerRegistry.shared.register(token: token) { _ in
            let data = Data(json.utf8)
            let response = try #require(
                HTTPURLResponse(
                    url: responseURL,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
            )
            return (response, data)
        }
        defer { TestMockURLHandlerRegistry.shared.unregister(token: token) }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [TestMockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let manager = NetworkManager(session: session)

        let iterations = 48
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0 ..< iterations {
                group.addTask {
                    let strategy: JSONDecoder.DateDecodingStrategy = (index % 2 == 0) ? .deferredToDate : .iso8601
                    let base = RequestConfig(
                        host: "api.test",
                        path: "/users",
                        provider: .network,
                        dateDecodeStrategy: strategy,
                        debugMode: false
                    )
                    let config = requestConfigAddingMockToken(base, token: token)
                    let result: (MockUser, ResponseHeader?) = try await manager.request(with: config)
                    #expect(result.0.name == "Concurrent")
                    #expect(result.0.email == "c@example.com")
                }
            }
            for try await _ in group {}
        }
    }
}
