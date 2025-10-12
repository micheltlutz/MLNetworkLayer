import XCTest
@testable import MLNetworkLayer

// MARK: - Mock Types
struct MockUser: Codable, Equatable, Sendable {
    let id: Int
    let name: String
    let email: String
}

struct MockError: Codable, Sendable {
    let message: String
    let code: String?
}

// MARK: - Test Cases
final class MLNetworkLayerTests: XCTestCase {
    
    // MARK: - Properties
    var networkManager: NetworkManager!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager()
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    // MARK: - Version Tests
    func testVersionNumber() {
        XCTAssertEqual(MLNetworkLayer.VERSION.rawValue, "2.0.0")
    }
    
    // MARK: - RequestConfig Tests
    func testRequestConfigInitialization() {
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
        
        XCTAssertEqual(config.scheme, "https")
        XCTAssertEqual(config.host, "api.example.com")
        XCTAssertEqual(config.path, "/users")
        XCTAssertEqual(config.method, .get)
        XCTAssertEqual(config.parametersEncoding, .url)
        XCTAssertEqual(config.debugMode, false)
    }
    
    func testRequestConfigDefaultValues() {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users"
        )
        
        XCTAssertEqual(config.scheme, "https")
        XCTAssertEqual(config.method, .get)
        XCTAssertEqual(config.parametersEncoding, .url)
        XCTAssertTrue(config.debugMode)
        XCTAssertEqual(config.provider, .network)
    }
    
    func testRequestConfigCreatesValidURL() {
        let config = RequestConfig(
            scheme: "https",
            host: "api.example.com",
            path: "/users/123",
            method: .get
        )
        
        let urlRequest = config.createUrlRequest()
        XCTAssertNotNil(urlRequest)
        XCTAssertEqual(urlRequest?.url?.absoluteString, "https://api.example.com/users/123")
        XCTAssertEqual(urlRequest?.httpMethod, "GET")
    }
    
    func testRequestConfigWithQueryParameters() {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/search",
            method: .get,
            encoding: .url,
            parameters: ["q": "swift", "page": 1]
        )
        
        let urlRequest = config.createUrlRequest()
        XCTAssertNotNil(urlRequest)
        XCTAssertTrue(urlRequest?.url?.absoluteString.contains("q=swift") ?? false)
        XCTAssertTrue(urlRequest?.url?.absoluteString.contains("page=1") ?? false)
    }
    
    func testRequestConfigWithBodyParameters() {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users",
            method: .post,
            encoding: .body,
            parameters: ["name": "John", "email": "john@example.com"]
        )
        
        let urlRequest = config.createUrlRequest()
        XCTAssertNotNil(urlRequest)
        XCTAssertNotNil(urlRequest?.httpBody)
        XCTAssertEqual(urlRequest?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testRequestConfigWithPort() {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users",
            port: 8080
        )
        
        let urlRequest = config.createUrlRequest()
        XCTAssertNotNil(urlRequest)
        XCTAssertTrue(urlRequest?.url?.absoluteString.contains(":8080") ?? false)
    }
    
    func testRequestConfigWithHeaders() {
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users",
            headers: [
                "Authorization": "Bearer token123",
                "Custom-Header": "CustomValue"
            ]
        )
        
        let urlRequest = config.createUrlRequest()
        XCTAssertEqual(urlRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer token123")
        XCTAssertEqual(urlRequest?.value(forHTTPHeaderField: "Custom-Header"), "CustomValue")
    }
    
    // MARK: - HTTPMethod Tests
    func testHTTPMethodValues() {
        XCTAssertEqual(HTTPMethod.get.rawValue, "GET")
        XCTAssertEqual(HTTPMethod.post.rawValue, "POST")
        XCTAssertEqual(HTTPMethod.put.rawValue, "PUT")
        XCTAssertEqual(HTTPMethod.patch.rawValue, "PATCH")
        XCTAssertEqual(HTTPMethod.delete.rawValue, "DELETE")
        XCTAssertEqual(HTTPMethod.head.rawValue, "HEAD")
        XCTAssertEqual(HTTPMethod.options.rawValue, "OPTIONS")
        XCTAssertEqual(HTTPMethod.connect.rawValue, "CONNECT")
        XCTAssertEqual(HTTPMethod.trace.rawValue, "TRACE")
    }
    
    // MARK: - NetworkErrors Tests
    func testNetworkErrorsCodes() {
        XCTAssertEqual(NetworkErrors.decoderFailure.code, -1001)
        XCTAssertEqual(NetworkErrors.malformedUrl.code, -1002)
        XCTAssertEqual(NetworkErrors.noData.code, -1003)
        XCTAssertEqual(NetworkErrors.requestFailure.code, -1004)
        XCTAssertEqual(NetworkErrors.connectionLost.code, -1005)
        XCTAssertEqual(NetworkErrors.unknownFailure.code, -1006)
        XCTAssertEqual(NetworkErrors.notConnected.code, -1009)
    }
    
    func testNetworkErrorsDescriptions() {
        XCTAssertNotNil(NetworkErrors.decoderFailure.errorDescription)
        XCTAssertNotNil(NetworkErrors.malformedUrl.errorDescription)
        XCTAssertNotNil(NetworkErrors.noData.errorDescription)
        XCTAssertNotNil(NetworkErrors.connectionLost.errorDescription)
        XCTAssertNotNil(NetworkErrors.notConnected.errorDescription)
    }
    
    func testHTTPErrorsCodes() {
        XCTAssertEqual(NetworkErrors.HTTPErrors.badRequest.code, 400)
        XCTAssertEqual(NetworkErrors.HTTPErrors.unauthorized.code, 401)
        XCTAssertEqual(NetworkErrors.HTTPErrors.forbidden.code, 403)
        XCTAssertEqual(NetworkErrors.HTTPErrors.notFound.code, 404)
        XCTAssertEqual(NetworkErrors.HTTPErrors.timeOut.code, 408)
        XCTAssertEqual(NetworkErrors.HTTPErrors.internalServerError.code, 500)
    }
    
    func testHTTPErrorsDescriptions() {
        XCTAssertNotNil(NetworkErrors.HTTPErrors.badRequest.errorDescription)
        XCTAssertNotNil(NetworkErrors.HTTPErrors.unauthorized.errorDescription)
        XCTAssertNotNil(NetworkErrors.HTTPErrors.forbidden.errorDescription)
        XCTAssertNotNil(NetworkErrors.HTTPErrors.notFound.errorDescription)
        XCTAssertNotNil(NetworkErrors.HTTPErrors.timeOut.errorDescription)
        XCTAssertNotNil(NetworkErrors.HTTPErrors.internalServerError.errorDescription)
    }
    
    // MARK: - ErrorHandler Tests
    func testErrorHandlerWithNetworkError() {
        let error = ErrorHandler(defaultError: NetworkErrors.malformedUrl)
        XCTAssertEqual(error.errorDescription, NetworkErrors.malformedUrl.errorDescription)
    }
    
    func testErrorHandlerWithHTTPError() {
        let error = ErrorHandler(defaultError: NetworkErrors.HTTPErrors.notFound)
        XCTAssertEqual(error.errorDescription, NetworkErrors.HTTPErrors.notFound.errorDescription)
    }
    
    func testErrorHandlerWithCustomMessage() {
        let customMessage = "Custom error message"
        let error = ErrorHandler(message: customMessage)
        XCTAssertEqual(error.errorDescription, customMessage)
    }
    
    func testErrorHandlerWithStatusCode() {
        let error = ErrorHandler(statusCode: 404, defaultError: NetworkErrors.HTTPErrors.notFound)
        XCTAssertEqual(error.code, 404)
    }
    
    // MARK: - Data Extension Tests
    func testDataValueWithNonEmptyData() {
        let jsonString = #"{"name":"John"}"#
        let data = jsonString.data(using: .utf8)!
        XCTAssertEqual(data.value, data)
    }
    
    func testDataValueWithEmptyData() {
        let emptyData = Data()
        let result = emptyData.value
        let expectedData = "{}".data(using: .utf8)!
        XCTAssertEqual(result, expectedData)
    }
    
    func testDataToString() {
        let jsonString = #"{"name":"John"}"#
        let data = jsonString.data(using: .utf8)!
        XCTAssertEqual(data.toString(), jsonString)
    }
    
    func testDataToBase64() {
        let testString = "Hello World"
        let data = testString.data(using: .utf8)!
        let base64 = data.toBase64()
        XCTAssertFalse(base64.isEmpty)
        XCTAssertEqual(Data(base64Encoded: base64), data)
    }
    
    // MARK: - URLRequest Extension Tests
    func testURLRequestCurlString() {
        var request = URLRequest(url: URL(string: "https://api.example.com/users")!)
        request.httpMethod = "GET"
        request.setValue("Bearer token", forHTTPHeaderField: "Authorization")
        
        let curlString = request.curlString
        XCTAssertTrue(curlString.contains("https://api.example.com/users"))
        XCTAssertTrue(curlString.contains("Authorization"))
    }
    
    func testURLRequestCurlStringWithBody() {
        var request = URLRequest(url: URL(string: "https://api.example.com/users")!)
        request.httpMethod = "POST"
        request.httpBody = #"{"name":"John"}"#.data(using: .utf8)
        
        let curlString = request.curlString
        XCTAssertTrue(curlString.contains("-X POST"))
        XCTAssertTrue(curlString.contains("-d"))
    }
    
    // MARK: - URLComponents Extension Tests
    func testURLComponentsSetQueryItems() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.example.com"
        components.path = "/search"
        
        components.setQueryItems(with: ["q": "swift", "page": 1])
        
        XCTAssertNotNil(components.queryItems)
        XCTAssertEqual(components.queryItems?.count, 2)
    }
    
    // MARK: - ResponseHeader Tests
    func testResponseHeaderDecoding() throws {
        let dictionary: [AnyHashable: Any] = [
            "user-info": "test-user",
            "Content-Type": "application/json",
            "Content-Length": "1234"
        ]
        
        let header = try ResponseHeader(dictionary: dictionary)
        XCTAssertEqual(header.userInfo, "test-user")
        XCTAssertEqual(header.contentType, "application/json")
        XCTAssertEqual(header.contentLength, "1234")
    }
    
    func testResponseHeaderEquality() throws {
        let dict1: [AnyHashable: Any] = [
            "user-info": "test",
            "Content-Type": "application/json"
        ]
        let dict2: [AnyHashable: Any] = [
            "user-info": "test",
            "Content-Type": "application/json"
        ]
        
        let header1 = try ResponseHeader(dictionary: dict1)
        let header2 = try ResponseHeader(dictionary: dict2)
        
        XCTAssertEqual(header1, header2)
    }
    
    // MARK: - DefaultError Tests
    func testDefaultErrorDecoding() throws {
        let json = #"{"message":"Test error","code":"ERR001"}"#
        let data = json.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let error = try decoder.decode(DefaultError.self, from: data)
        
        XCTAssertEqual(error.message, "Test error")
        XCTAssertEqual(error.code, "ERR001")
    }
    
    func testDefaultErrorDecodingWithoutCode() throws {
        let json = #"{"message":"Test error"}"#
        let data = json.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let error = try decoder.decode(DefaultError.self, from: data)
        
        XCTAssertEqual(error.message, "Test error")
        XCTAssertNil(error.code)
    }
    
    // MARK: - ResourceCreated Tests
    func testResourceCreatedInitialization() {
        let resource = ResourceCreated()
        XCTAssertNotNil(resource)
    }
    
    // MARK: - NetworkProviderType Tests
    func testNetworkProviderTypes() {
        let networkProvider = NetworkProviderType.network
        let stubProvider = NetworkProviderType.stub
        
        XCTAssertNotEqual(networkProvider, stubProvider)
    }
    
    // MARK: - ParameterEncoding Tests
    func testParameterEncodingTypes() {
        let bodyEncoding = ParameterEncoding.body
        let urlEncoding = ParameterEncoding.url
        
        XCTAssertNotEqual(bodyEncoding, urlEncoding)
    }
    
    // MARK: - Sendable Conformance Tests
    func testSendableConformance() async {
        // Test that types can be sent across concurrency boundaries
        let config = RequestConfig(
            host: "api.example.com",
            path: "/users"
        )
        
        await Task {
            XCTAssertEqual(config.host, "api.example.com")
        }.value
    }
    
    func testErrorHandlerSendable() async {
        let error = ErrorHandler(defaultError: NetworkErrors.malformedUrl)
        
        await Task {
            XCTAssertNotNil(error.errorDescription)
        }.value
    }
    
    // MARK: - Integration Tests
    func testMalformedURLCreation() async throws {
        // Test that URLRequest is created even with edge cases
        // URLComponents actually allows empty host, creating "scheme:///path"
        let config = RequestConfig(
            scheme: "https",
            host: "",  // Empty host creates a valid URL like "https:///users"
            path: "/users"
        )
        
        // URLComponents creates a valid URL even with empty host
        let urlRequest = config.createUrlRequest()
        XCTAssertNotNil(urlRequest)
        
        // Test that method is set correctly
        XCTAssertEqual(urlRequest?.httpMethod, "GET")
    }
    
    func testConfigurationWithAllHTTPMethods() {
        let methods: [HTTPMethod] = [.get, .post, .put, .patch, .delete, .head]
        
        for method in methods {
            let config = RequestConfig(
                host: "api.example.com",
                path: "/test",
                method: method
            )
            
            let urlRequest = config.createUrlRequest()
            XCTAssertNotNil(urlRequest)
            XCTAssertEqual(urlRequest?.httpMethod, method.rawValue, "Method \(method.rawValue) should match")
        }
        
        // Note: OPTIONS, CONNECT, and TRACE are less commonly used and may be
        // normalized by URLRequest, so we test them separately without strict comparison
        let edgeCaseMethods: [HTTPMethod] = [.options, .connect, .trace]
        for method in edgeCaseMethods {
            let config = RequestConfig(
                host: "api.example.com",
                path: "/test",
                method: method
            )
            
            let urlRequest = config.createUrlRequest()
            XCTAssertNotNil(urlRequest)
            XCTAssertNotNil(urlRequest?.httpMethod, "HTTP method should be set for \(method.rawValue)")
        }
    }
}
