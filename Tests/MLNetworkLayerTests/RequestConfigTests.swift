import Foundation
import Testing
@testable import MLNetworkLayer

struct RequestConfigTests {
    @Test
    func requestConfigInitialization() {
        let config = RequestConfig(
            scheme: "https",
            host: "api.example.com",
            path: "/users",
            method: .get,
            encoding: .url,
            parameters: ["page": 1],
            headers: ["Authorization": "Bearer token"],
            debugMode: false
        )

        #expect(config.scheme == "https")
        #expect(config.host == "api.example.com")
        #expect(config.path == "/users")
        #expect(config.method == .get)
        #expect(config.parametersEncoding == .url)
        #expect(config.debugMode == false)
    }

    @Test
    func requestConfigDefaultValues() {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users"
        )

        #expect(config.scheme == "https")
        #expect(config.method == .get)
        #expect(config.parametersEncoding == .url)
        #expect(config.debugMode == true)
        #expect(config.provider == .network)
    }

    /// Garante que o provider stub pode ser selecionado com `bundleClass` (exigido pela API).
    @Test
    func requestConfigStubProvider() {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users",
            provider: .stub,
            bundleClass: NetworkManager.self,
            debugMode: false
        )
        #expect(config.provider == .stub)
        #expect(config.bundleClass != nil)
    }

    @Test
    func requestConfigCreatesValidURL() throws {
        let config = RequestConfig(
            scheme: "https",
            host: "api.example.com",
            path: "/users/123",
            method: .get
        )

        let urlRequest = config.createUrlRequest()
        let request = try #require(urlRequest)
        #expect(request.url?.absoluteString == "https://api.example.com/users/123")
        #expect(request.httpMethod == "GET")
    }

    @Test
    func requestConfigWithQueryParameters() throws {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/search",
            method: .get,
            encoding: .url,
            parameters: ["q": "swift", "page": 1]
        )

        let urlRequest = try #require(config.createUrlRequest())
        let absolute = try #require(urlRequest.url?.absoluteString)
        #expect(absolute.contains("q=swift"))
        #expect(absolute.contains("page=1"))
    }

    @Test
    func requestConfigWithBodyParameters() throws {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users",
            method: .post,
            encoding: .body,
            parameters: ["name": "John", "email": "john@example.com"]
        )

        let urlRequest = try #require(config.createUrlRequest())
        #expect(urlRequest.httpBody != nil)
        #expect(urlRequest.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test
    func requestConfigWithPort() throws {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users",
            port: 8080
        )

        let urlRequest = try #require(config.createUrlRequest())
        let absolute = try #require(urlRequest.url?.absoluteString)
        #expect(absolute.contains(":8080"))
    }

    @Test
    func requestConfigWithHeaders() throws {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users",
            headers: [
                "Authorization": "Bearer token123",
                "Custom-Header": "CustomValue"
            ]
        )

        let urlRequest = try #require(config.createUrlRequest())
        #expect(urlRequest.value(forHTTPHeaderField: "Authorization") == "Bearer token123")
        #expect(urlRequest.value(forHTTPHeaderField: "Custom-Header") == "CustomValue")
    }

    @Test(arguments: [
        (HTTPMethod.get, "GET"),
        (HTTPMethod.post, "POST"),
        (HTTPMethod.put, "PUT"),
        (HTTPMethod.patch, "PATCH"),
        (HTTPMethod.delete, "DELETE"),
        (HTTPMethod.head, "HEAD"),
        (HTTPMethod.options, "OPTIONS"),
        (HTTPMethod.connect, "CONNECT"),
        (HTTPMethod.trace, "TRACE")
    ])
    func httpMethodRawValue(method: HTTPMethod, expected: String) {
        #expect(method.rawValue == expected)
    }

    @Test
    func sendableConformance() async {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users"
        )
        #expect(config.host == "api.example.com")
    }

    @Test
    func malformedURLCreation() throws {
        let config = RequestConfig(
            scheme: "https",
            host: "",
            path: "/users"
        )

        let urlRequest = try #require(config.createUrlRequest())
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test(arguments: [HTTPMethod.get, .post, .put, .patch, .delete, .head])
    func configurationUsesHTTPMethodOnURLRequest(method: HTTPMethod) throws {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/test",
            method: method
        )

        let urlRequest = try #require(config.createUrlRequest())
        #expect(urlRequest.httpMethod == method.rawValue)
    }

    @Test(arguments: [HTTPMethod.options, .connect, .trace])
    func configurationSetsEdgeCaseHTTPMethods(method: HTTPMethod) throws {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/test",
            method: method
        )

        let urlRequest = try #require(config.createUrlRequest())
        #expect(urlRequest.httpMethod != nil)
    }
}
