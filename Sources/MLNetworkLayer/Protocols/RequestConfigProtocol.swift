import Foundation

public protocol RequestConfigProtocol {
    /// The config's base `SCHEME` http, https.
    var scheme: String { get }
    
    /// The config's base `HOST`.
    var host: String { get }

    /// The path to be appended to `path` to form the full `URL`.
    var path: String { get }
    
    /// The path to be appended to `port` to form the full `URL`.
    var port: Int? { get }

    /// The HTTP method used in the request.
    var method: HTTPMethod { get }

    /// The URL parameters used in the request.
    var parameters: [String: Any] { get set }

    /// The headers parameters used in the request.
    var headers: [String: String] { get }

    /// The JSONDecoder dateDecodeStrategy used in the request.
    var dateDecodeStrategy: JSONDecoder.DateDecodingStrategy? { get }

    /// The `ParameterEncoding` used in the request. `ParameterEncoding.swift`
    var parametersEncoding: ParameterEncoding { get }

    /// Provides stub data for use in testing.
    var sampleData: Data? { get }

    /// Flag to print debug info in console
    var debugMode: Bool { get }

    /// indicates which data provider will be used.
    var provider: NetworkProviderType { get set }

    /// Provides a bundle class for provider use with stub
    var bundleClass: AnyClass? { get set }
}

extension RequestConfigProtocol {
    /**
     This function create and return an UrlRequest

     - Parameter config: The inplementation of `RequestConfigProtocol`

     - Returns: `URLRequest?`
    */
    func createUrlRequest() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.port = port

        guard let url = urlComponents.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "\(method)"

        var httpBody: Data?

        if parameters.isEmpty == false {
            switch parametersEncoding {
            case .url:
                urlComponents.setQueryItems(with: parameters)
                request.url = urlComponents.url
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

            case .body:
                httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        if let body = httpBody {
            request.httpBody = body
        }

        request.allHTTPHeaderFields = headers

        return request
    }
}
