import Foundation

/// This implementation for `RequestConfigProtocol` form generic requests
public struct RequestConfig: RequestConfigProtocol {
    /// The base host form Request
    public var host: String

    /// The endpoint path to complete url for request
    public var path: String

    /// The `HTTPMethod` `(.connect, .delete, .get, .head, .options, .patch, .post, .put, .trace)` default `.get`
    public var method: HTTPMethod

    /// The `[String: Any]` parameters
    public var parameters: [String: Any]

    /// The `[String: String]` headers
    public var headers: [String: String]

    /// The `JSONDecoder.DateDecodingStrategy`
    public var dateDecodeStrategy: JSONDecoder.DateDecodingStrategy?

    /// The request `parametersEncoding` `.url` or `.body`
    public var parametersEncoding: ParameterEncoding

    /// Sample data to stub request: * not used now is utils for UnitTests
    public var sampleData: Data?

    /// Flag to print debug info in console
    public var debugMode: Bool

    /// indicates which data provider will be used.
    public var provider: NetworkProviderType

    /// Provides a bundle class for provider use with stub
    public var bundleClass: AnyClass?

    /**
     Initializes a new `RequestConfig`

        - Parameters:
           - host: The base host form Request default value global config constant `linkServerRaw`
           - path: The endpoint path to complete url for request
           - provider: The data provider `(.network, .stub)`
           - method: The `HTTPMethod` `(.connect, .delete, .get, .head, .options, .patch, .post, .put, .trace)` default `.get`
           - encoding: The request `parametersEncoding` `.url` or `.body` default `.url`
           - parameters: The `[String: Any]` parameters default `[:]`
           - headers: The `[String: String]` headers default `[:]`
           - bundleClass: The bundleClass `AnyClass`  default is nil
           - dateDecodeStrategy: The `JSONDecoder.DateDecodingStrategy` default `nil`
           - debugMode: Toggle debug mode default `false`
    */
    public init(host: String,
                path: String,
                provider: NetworkProviderType = .network,
                method: HTTPMethod = .get,
                encoding: ParameterEncoding = .url,
                parameters: [String: Any] = [:],
                headers: [String: String] = [:],
                bundleClass: AnyClass? = nil,
                dateDecodeStrategy: JSONDecoder.DateDecodingStrategy? = nil,
                debugMode: Bool = true) {
        self.host = host
        self.path = path
        self.provider = provider
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.bundleClass = bundleClass
        self.dateDecodeStrategy = dateDecodeStrategy
        self.parametersEncoding = encoding
        self.debugMode = debugMode

        if provider == .stub && bundleClass == nil {
            fatalError("To use .stub network provide a bundleCalss")
        }
    }
}
