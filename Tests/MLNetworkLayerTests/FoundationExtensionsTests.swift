import Foundation
import Testing
@testable import MLNetworkLayer

struct FoundationExtensionsTests {
    @Test
    func dataValueWithNonEmptyData() throws {
        let jsonString = #"{"name":"John"}"#
        let data = try #require(jsonString.data(using: .utf8))
        #expect(data.value == data)
    }

    @Test
    func dataValueWithEmptyData() throws {
        let emptyData = Data()
        let result = emptyData.value
        let expectedData = try #require("{}".data(using: .utf8))
        #expect(result == expectedData)
    }

    @Test
    func dataToString() throws {
        let jsonString = #"{"name":"John"}"#
        let data = try #require(jsonString.data(using: .utf8))
        #expect(data.toString() == jsonString)
    }

    @Test
    func dataToBase64() throws {
        let testString = "Hello World"
        let data = try #require(testString.data(using: .utf8))
        let base64 = data.toBase64()
        #expect(base64.isEmpty == false)
        #expect(Data(base64Encoded: base64) == data)
    }

    @Test
    func urlRequestCurlString() throws {
        let url = try #require(URL(string: "https://api.example.com/users"))
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")

        let curlString = request.curlString
        #expect(curlString.contains("https://api.example.com/users"))
        #expect(curlString.contains("Authorization"))
    }

    @Test
    func urlRequestCurlStringWithBody() throws {
        let url = try #require(URL(string: "https://api.example.com/users"))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = #"{"name":"John"}"#.data(using: .utf8)

        let curlString = request.curlString
        #expect(curlString.contains("-X POST"))
        #expect(curlString.contains("-d"))
    }

    @Test
    func urlComponentsSetQueryItems() throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.example.com"
        components.path = "/search"

        components.setQueryItems(with: ["q": "swift", "page": 1])

        let items = try #require(components.queryItems)
        #expect(items.count == 2)
    }
}
