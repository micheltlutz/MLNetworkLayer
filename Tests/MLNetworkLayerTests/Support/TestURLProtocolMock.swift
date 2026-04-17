import Foundation
import MLNetworkLayer

/// Cabeçalho interno só para testes: associa o pedido ao handler registado (seguro com testes paralelos).
enum TestMockURLProtocolConstants {
    static let mockTokenHeaderField = "X-MLNetworkLayerTests-Mock-Token"
}

final class TestMockURLHandlerRegistry: @unchecked Sendable {
    static let shared = TestMockURLHandlerRegistry()

    private let lock = NSLock()
    private var handlers: [String: @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)] = [:]

    func register(
        token: String,
        handler: @escaping @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)
    ) {
        lock.lock()
        defer { lock.unlock() }
        handlers[token] = handler
    }

    func unregister(token: String) {
        lock.lock()
        defer { lock.unlock() }
        handlers.removeValue(forKey: token)
    }

    func handler(forToken token: String) -> (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))? {
        lock.lock()
        defer { lock.unlock() }
        return handlers[token]
    }
}

final class TestMockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        request.value(forHTTPHeaderField: TestMockURLProtocolConstants.mockTokenHeaderField) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard
            let token = request.value(forHTTPHeaderField: TestMockURLProtocolConstants.mockTokenHeaderField),
            let handler = TestMockURLHandlerRegistry.shared.handler(forToken: token)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

func requestConfigAddingMockToken(_ config: RequestConfig, token: String) -> RequestConfig {
    var copy = config
    copy.headers[TestMockURLProtocolConstants.mockTokenHeaderField] = token
    return copy
}
